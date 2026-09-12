import 'routes.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:connectify/firebase_options.dart';
import 'package:connectify/services/notification_service.dart';
import 'package:connectify/services/theme_service.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");
  await NotificationService.instance.initialize();
  await ThemeService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          navigatorKey: NotificationService.instance.navigatorKey,
          scaffoldMessengerKey: NotificationService.instance.scaffoldMessengerKey,
          debugShowCheckedModeBanner: false,
          title: 'Connectify',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          routes: appRoutes,
        );
      },
    );
  }
}


