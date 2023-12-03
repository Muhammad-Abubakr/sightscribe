import 'dart:convert';
import 'dart:isolate';

import 'package:camera_bg/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:sightscribe/blocs/detected_objects/detected_objects_cubit.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

// CONSTANTS
const _stopStreamingButtonID = "CAMERA_STREAM";
final _wsUrl = Uri.parse('ws://192.168.43.217:8000/stream/image/');

/// Task Handler that is run as the foreground service
class CameraStreamForegroundHandler extends TaskHandler {
  late WebSocketChannel _channel;
  late CameraController _cameraController;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _channel = WebSocketChannel.connect(_wsUrl);

    /// This Listener will restart the stream and socket connection,
    /// if it disconnects
    _channel.stream.listen((data) {
      sendPort?.send(data);
    },
      onDone: () async {
        _channel = WebSocketChannel.connect(_wsUrl);
        await FlutterForegroundTask.restartService();
      },
      onError: (error) async {
        _channel = WebSocketChannel.connect(_wsUrl);
        await FlutterForegroundTask.restartService();
      }
    );

    // Initialize the camera controller
    final cameras = await availableCameras();
    _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.low,
        imageFormatGroup: ImageFormatGroup.jpeg,
        enableAudio: false,
    );
    await _cameraController.initialize();

    // Start streaming camera frames
    startStreaming();
  }

  /// Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    _channel.sink.add(jsonEncode({"ping": "keep-alive"}));
  }

  /// Called when the notification button on the Android platform is pressed.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Clean up resources when the task is stopped
    _channel.sink.close();
    await _cameraController.dispose();
  }

  /// Called when [NotificationButton] is pressed
  @override
  void onNotificationButtonPressed(String id) async {
    if (id == _stopStreamingButtonID) {
      await FlutterForegroundTask.stopService();
    }
    super.onNotificationButtonPressed(id);
  }

  // Helper Functions
  // Function to start streaming camera frames
  Future<void> startStreaming() async {
    _cameraController.startImageStream((CameraImage image) {
      // Process the camera image and send it through WebSocket
      final Uint8List imageData = concatenatePlanes(image.planes);
      _channel.sink.add(imageData);
    });
  }

  Uint8List concatenatePlanes(planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

}


/// The callback function should always be a top-level function. Should
/// be invoked only after `initForegroundTask` has been called
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(CameraStreamForegroundHandler());
}

/// This method should be called first before the `startCallback` is
/// invoked
void initForegroundTask() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'sightscribe_camera_stream_daemon',
      channelName: 'SightScribe Camera Stream',
      channelDescription: 'This notification appears when the foreground '
          'service is running.',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
      buttons: [
        const NotificationButton(
          id: _stopStreamingButtonID,
          text: "Stop Streaming",
        ),
      ],
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 1000,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

}
