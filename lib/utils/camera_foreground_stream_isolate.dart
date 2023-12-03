import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:camera_bg/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
// import 'package:web_socket_channel/status.dart' as status;

// CONSTANTS
const _stopStreamingButtonID = "CAMERA_STREAM";
final _wsUrl = Uri.parse('ws://192.168.43.217:8000/stream/image/');
const int _framesPerSecond = 2;   // Throttling Parameter I
final int _delayMilliseconds = (1000 / _framesPerSecond).round(); // Throttling Parameter II

/// Task Handler that is run as the foreground service
class CameraStreamForegroundHandler extends TaskHandler {
  late WebSocketChannel _channel;
  late CameraController _cameraController;
  final StreamController<bool> _frameRateController = StreamController<bool>();
  bool _canSendFrame = false;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp, SendPort? sendPort) async {
    _channel = WebSocketChannel.connect(_wsUrl);

    // This Listener will restart the stream and socket connection,
    // if it disconnects
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

    // Periodically send a signal to allow sending the next frame
    Timer.periodic(Duration(milliseconds: _delayMilliseconds), (timer) {
      _frameRateController.add(true);
    });

    // register the throttler
    _registerThrottler();

    // Start streaming camera frames
    _startStreaming();
  }

  /// Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    _channel.sink.add(jsonEncode({"ping": "keep-alive"}));
  }

  /// Called when the [FlutterForegroundTask] exits.
  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) async {
    // Clean up resources when the task is stopped
    await _channel.sink.close();
    await _cameraController.dispose();
    await _frameRateController.close();
  }

  /// Called when [NotificationButton] is pressed, if so stop the ForegroundTask
  /// and exit the application
  @override
  void onNotificationButtonPressed(String id) async {
    if (id == _stopStreamingButtonID) {
      await FlutterForegroundTask.stopService();
      exit(0);
    }
    super.onNotificationButtonPressed(id);
  }

  /*
   * Helper Functions
   */
  /// Function to start streaming camera frames. It Checks if a frame
  /// can be sent using [canSendFrame] and [_frameRateController] based
  /// on the desired frame rate, if so then Process the camera image and
  /// send it through WebSocket
  Future<void> _startStreaming() async {
    _cameraController.startImageStream((CameraImage image) async {
      if (_canSendFrame) {
        final Uint8List imageData = _concatenatePlanes(image.planes);
        _channel.sink.add(imageData);

        // Regain the Throttle flag
        _frameRateController.add(false);
      }
    });
  }

  /// Concatenate byte planes to a single [Uint8List] that can be sent
  /// through the [Socket]
  Uint8List _concatenatePlanes(planes) {
    final WriteBuffer allBytes = WriteBuffer();
    for (var plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }


  /// Register a listener to [\_frameRateController] to control [\_canSendFrame]
  void _registerThrottler() {
    _frameRateController.stream.listen((canSendOrNot) {
        _canSendFrame = canSendOrNot;
    });
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
      interval: 5000,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );

}
