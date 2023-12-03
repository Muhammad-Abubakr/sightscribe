import 'dart:async';
import 'dart:isolate';

// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:camera_bg/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:sightscribe/utils/permission_handler.dart';

import '../../utils/camera_foreground_stream_isolate.dart';

part 'camera_isolate_event.dart';
part 'camera_isolate_state.dart';


class CameraIsolateBloc extends Bloc<CameraIsolateEvent, CameraIsolateState> {
  ReceivePort? _receivePort;

  CameraIsolateBloc() : super(CameraIsolateStateInitial()) {
    // Map<Events, EventHandlers>
    on<InitEvent>(_isolator);
    on<ErrorEvent>(_updateCameraIsolateErrorState);
  }

  /// Handles the Camera Foreground Service
  FutureOr<void> _isolator(InitEvent event, Emitter<CameraIsolateState> emit) async {
    try {
      // get required permissions
      await checkPermissions();
      // Configure the foreground task for Android and IOS
      initForegroundTask();

      // receiver port initialization
      _receivePort = FlutterForegroundTask.receivePort;
      final bool isRegistered = _registerReceivePort(_receivePort);
      if (!isRegistered) {
        debugPrint('Failed to register receivePort!');
      }

      // ...
      if (await FlutterForegroundTask.isRunningService) {
        FlutterForegroundTask.restartService();
      } else {
         FlutterForegroundTask.startService(
          notificationTitle: 'Camera Daemon is running',
          notificationText: 'Tap to return to the app',
          callback: startCallback,
        );
      }
    } on CameraException catch (e) {
      emit(CameraIsolateStateError(error: e));
    }
  }

  /// Register the receiving port listener and handles the data being
  /// sent from the foreground service thread to the main thread
  bool _registerReceivePort(ReceivePort? newReceivePort) {
    if (newReceivePort == null) {
      return false;
    }
    _closeReceivePort();

    _receivePort = newReceivePort;
    _receivePort?.listen((data) {
      debugPrint(data);
    });

    return _receivePort != null;
  }

  /// ... Destructor
  void _closeReceivePort() {
    _receivePort?.close();
    _receivePort = null;
  }

  /// Emits the Error state and inform the Flutter app to response
  FutureOr<void> _updateCameraIsolateErrorState(ErrorEvent event, Emitter<CameraIsolateState> emit) {}
}

