import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> init() async {
    // Request permission
    await _firebaseMessaging.requestPermission();

    // Get token
    final token = await _firebaseMessaging.getToken();
    debugPrint("🔥 FCM TOKEN: $token");

    // Foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("📩 Notification received");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");

      
    });
  }
  
}
