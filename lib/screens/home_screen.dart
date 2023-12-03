import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/ui/with_foreground_task.dart';

import 'package:sightscribe/blocs/detected_objects/detected_objects_cubit.dart';


class HomeScreen extends StatelessWidget {
  static const String route = "/";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: Scaffold(
        body: BlocBuilder<DetectedObjectsCubit, DetectedObjectsState>(
            builder: (context, state) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Detected Objects",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    state.objects ?? "OK",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}
