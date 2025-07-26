import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    await _requestPermissions();
    await _initLocalNotifications();
    await _registerFCMToken();
    _handleForegroundMessages();
    _handleNotificationTap();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      await _firebaseMessaging.requestPermission();
    }
  }

  Future<void> _registerFCMToken() async {
    String? token = await _firebaseMessaging.getToken();
    print("🔥 FCM Token: $token");

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      print("🔄 Token refreshed: $newToken");
    });
  }

  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings iOSInit = DarwinInitializationSettings();

    await _localNotifications.initialize(
      InitializationSettings(android: androidInit, iOS: iOSInit),
      onDidReceiveNotificationResponse: (payload) {
        // Handle tapped notification from background/terminated
        _onNotificationTap(payload.payload);
      },
    );
  }

  void _handleForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📨 Foreground message: ${message.notification?.title}");

      // Show local notification
      _showLocalNotification(message);
    });
  }

  void _handleNotificationTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _onNotificationTap(message.data);
    });

    // For terminated state
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        _onNotificationTap(message.data);
      }
    });
  }

  void _onNotificationTap(dynamic data) {
    // Navigate based on notification data
    print("🧭 Navigate based on: $data");

    // Example:
    // if (data['screen'] == 'chat') {
    //   Get.to(() => ChatScreen(chatId: data['chatId']));
    // }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Default Channel',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: message.data.toString(), // can be JSON string too
    );
  }
}
