import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';

/// Checks for permissions and get them if not already granted
Future<void> checkPermissions() async {
    await Permission.camera.request();
    await Permission.location.request();
    await Permission.ignoreBatteryOptimizations.request();
    await Permission.microphone.request();

    final NotificationPermission notificationPermissionStatus =
    await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
}