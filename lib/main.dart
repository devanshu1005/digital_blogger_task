import 'package:digital_blogger_task/firebase_options.dart';
import 'package:digital_blogger_task/providers/video_provider.dart';
import 'package:digital_blogger_task/screens/home_screen.dart';
import 'package:digital_blogger_task/screens/live_video_screen.dart';
import 'package:digital_blogger_task/screens/splash_screen.dart';
import 'package:digital_blogger_task/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  runApp(
    ChangeNotifierProvider(
      create: (_) => VideoProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Digital Blogger Task',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/video-stream': (context) => LiveVideoScreen(),
      },
    );
  }
}