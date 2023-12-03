import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sightscribe/blocs/camera/camera_isolate_bloc.dart';
import 'package:sightscribe/blocs/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CameraIsolateBloc cameraIsolateBloc = CameraIsolateBloc()..add(InitEvent());

  runApp(MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => cameraIsolateBloc,
        ),
      ],
      child: const CameraApp()
  ));
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: HomeScreen.route,
      routes: {
        HomeScreen.route : (_) => const HomeScreen()
      },
    );
  }
}
