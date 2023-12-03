import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'detected_objects_state.dart';

class DetectedObjectsCubit extends Cubit<DetectedObjectsState> {
  DetectedObjectsCubit() : super(const DetectedObjectsInitial(objects: ""));

  /// This method is used to update the detected objects passed
  /// from the server
  void updateDetectedObjects(String objects) {
    emit(DetectedObjectsUpdate(objects: objects));
  }
}
