import 'package:digital_blogger_task/firebase_options.dart';
import 'package:digital_blogger_task/screens/home_screen.dart';
import 'package:digital_blogger_task/screens/splash_screen.dart';
import 'package:digital_blogger_task/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // <-- Add this line first

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);

  await NotificationService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Splash Example',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}