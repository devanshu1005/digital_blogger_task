import 'package:digital_blogger_task/firebase_options.dart';
import 'package:digital_blogger_task/providers/video_provider.dart';
import 'package:digital_blogger_task/providers/theme_provider.dart';
import 'package:digital_blogger_task/screens/home_screen.dart';
import 'package:digital_blogger_task/screens/live_video_screen.dart';
import 'package:digital_blogger_task/screens/notification_screen.dart';
import 'package:digital_blogger_task/screens/splash_screen.dart';
import 'package:digital_blogger_task/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

RemoteMessage? initialMessage;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().init();

  // Fetch initial message when app is launched from terminated state
  initialMessage = await FirebaseMessaging.instance.getInitialMessage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          title: 'Digital Blogger Task',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.lightTheme,
          darkTheme: themeProvider.darkTheme,
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(initialMessage: initialMessage),
            '/home': (context) => const HomeScreen(),
            '/video-stream': (context) => const LiveVideoScreen(),
            '/notification-test': (context) => const NotificationTestScreen(),
          },
        );
      },
    );
  }
}
