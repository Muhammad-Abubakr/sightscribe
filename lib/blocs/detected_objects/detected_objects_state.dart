part of 'detected_objects_cubit.dart';

@immutable
abstract class DetectedObjectsState {
  final String? objects;

  const DetectedObjectsState({this.objects});
}

class DetectedObjectsInitial extends DetectedObjectsState {
  const DetectedObjectsInitial({super.objects});
}

class DetectedObjectsUpdate extends DetectedObjectsState {
  const DetectedObjectsUpdate({required super.objects});
}
