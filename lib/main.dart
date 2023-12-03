import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sightscribe/blocs/camera/camera_isolate_bloc.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  CameraIsolateBloc cameraIsolateBloc = CameraIsolateBloc()..add(InitEvent());

  runApp(MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => cameraIsolateBloc,
        ),
      ],
      child: const App()
  ));
}

class App extends StatelessWidget {
  const App({super.key});

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
