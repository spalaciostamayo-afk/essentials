import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/app_navigation.dart';
import 'services/bluetooth_code_handler.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await NotificationService.initialize();

  runApp(const EssentialsApp());
}

class EssentialsApp extends StatelessWidget {
  const EssentialsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: essentialsNavigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'ESSENTIALS',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
      builder: (context, child) {
        return BluetoothCodeHandler(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}