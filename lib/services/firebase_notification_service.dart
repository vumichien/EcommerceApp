import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import '../models/Product.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static String? _fcmToken;
  static BuildContext? _context;

  /// Initialize Firebase Messaging
  static Future<void> initialize(BuildContext context) async {
    _context = context;

    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');

      try {
        // Get FCM token (may fail on simulator)
        _fcmToken = await _firebaseMessaging.getToken();
        print('🔥 FCM Token: $_fcmToken');
      } catch (e) {
        print('⚠️ FCM Token error (expected on iOS simulator): $e');
        // Continue without token - local notifications will still work
      }

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Setup message handlers
      _setupMessageHandlers();
    } else {
      print('User declined or has not accepted permission');
    }
  }

  /// Get FCM Token
  static String? getFCMToken() => _fcmToken;

  /// Force refresh FCM Token (useful for debug)
  static Future<String?> refreshFCMToken() async {
    try {
      // For iOS, we need to get APNS token first
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        print('🍎 Attempting to get APNS token first...');

        // Try to get APNS token with retry
        String? apnsToken;
        for (int i = 0; i < 5; i++) {
          try {
            apnsToken = await _firebaseMessaging.getAPNSToken();
            if (apnsToken != null) {
              print('✅ APNS Token obtained: ${apnsToken.substring(0, 20)}...');
              break;
            }
          } catch (e) {
            print('⚠️ APNS Token attempt ${i + 1} failed: $e');
          }

          // Wait before retry
          await Future.delayed(Duration(seconds: 2 + i));
        }

        if (apnsToken == null) {
          print('❌ Could not get APNS token - FCM will not work');
          return null;
        }
      }

      await _firebaseMessaging.deleteToken(); // Delete current token
      _fcmToken = await _firebaseMessaging.getToken(); // Get new token
      print('🔄 FCM Token refreshed: $_fcmToken');
      return _fcmToken;
    } catch (e) {
      print('❌ FCM Token refresh failed: $e');
      return null;
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Setup message handlers
  static void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is closed/background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is completely closed
    _handleInitialMessage();
  }

  /// Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  /// Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('Received background message: ${message.messageId}');
  }

  /// Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    _navigateBasedOnNotification(message.data);
  }

  /// Handle initial message when app is opened from notification
  static Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from notification: ${initialMessage.data}');
      // Delay navigation to ensure app is fully loaded
      Future.delayed(const Duration(seconds: 1), () {
        _navigateBasedOnNotification(initialMessage.data);
      });
    }
  }

  /// Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'Houzou Medical',
      message.notification?.body ?? 'New notification',
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }

  /// Handle local notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        Map<String, dynamic> data = jsonDecode(response.payload!);
        _navigateBasedOnNotification(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  /// Navigate based on notification data
  static void _navigateBasedOnNotification(Map<String, dynamic> data) {
    if (_context == null) return;

    final type = data['type'] ?? '';

    switch (type) {
      case 'home':
        // Navigate to home
        GoRouter.of(_context!).go('/home');
        break;

      case 'product_detail':
        final productId = data['product_id'];
        if (productId != null) {
          // Find product by ID
          final product = products.firstWhere(
            (p) => p.id.toString() == productId.toString(),
            orElse: () => products.first,
          );
          // Navigate to product detail
          GoRouter.of(_context!).go('/product/${product.id}');
        }
        break;

      default:
        // Default to home
        GoRouter.of(_context!).go('/home');
    }
  }

  /// Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }
}
