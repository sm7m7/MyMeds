import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service managing Firebase Cloud Messaging (FCM) push tokens and remote payloads.
class FcmService {
  FcmService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;
  bool _initialized = false;

  /// Initializes FCM listeners and requests push permissions.
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('FCM authorization status: ${settings.authorizationStatus}');

      // Retrieve device registration token
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM Device Token: $token');
      }

      // Listen for token refreshes
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        // In production, save new token to users/{uid}/fcmTokens
      });

      // Handle foreground push messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM foreground message received: ${message.notification?.title}');
      });

      _initialized = true;
    } catch (e) {
      debugPrint('FCM initialization failed (running in emulator or missing config): $e');
    }
  }

  /// Get current FCM token.
  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }
}
