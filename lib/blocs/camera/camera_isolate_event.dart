part of 'camera_isolate_bloc.dart';

abstract class CameraIsolateEvent {
  const CameraIsolateEvent();
}

// Initialization Event
class InitEvent extends CameraIsolateEvent {}

// Error Event
class ErrorEvent extends CameraIsolateEvent {
  final CameraException error;

  const ErrorEvent(this.error);
}