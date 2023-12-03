part of 'camera_isolate_bloc.dart';

abstract class CameraIsolateState {
  final CameraException? error;

  const CameraIsolateState({this.error});
}

class CameraIsolateStateInitial extends CameraIsolateState {}

class CameraIsolateStateError extends CameraIsolateState {
  const CameraIsolateStateError({required super.error});
}
