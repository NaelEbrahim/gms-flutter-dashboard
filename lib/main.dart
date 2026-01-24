import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter_windows/Bloc/Manager.dart';
import 'package:gms_flutter_windows/Modules/Base.dart';
import 'package:gms_flutter_windows/Remote/Dio_Linker.dart';
import 'package:gms_flutter_windows/Shared/Constant.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Screen Size
  await windowManager.ensureInitialized();
  await windowManager.setMinimumSize(const Size(680, 380));
  await windowManager.setMaximumSize(const Size(1920, 1080));
  // Initialize Dio
  Dio_Linker.init();
  runApp(BlocProvider(create: (_) => Manager(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    Constant.initializeScreenSize(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: AdminDashboard(),
    );
  }
}
