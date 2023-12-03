import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';

import '../blocs/camera/camera_isolate_bloc.dart';


class HomeScreen extends StatelessWidget {
  static const String route = "/";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        body: BlocBuilder<CameraIsolateBloc, CameraIsolateState>(
            builder: (context, state) => const Center(child: Text("OK"))
        ),
      ),
    );
  }
}
