import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:connectify/services/firestore_paths.dart';

/// Top-level background message handler for FCM.
/// Must be annotated with `@pragma('vm:entry-point')` so Flutter engine can invoke it.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM Background message received: ${message.messageId} - ${message.data}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  bool _isInitialized = false;

  /// Initializes FCM listeners, permissions, and handlers.
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Request notification permissions
    await requestPermission();

    // 2. Set background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 3. Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('FCM Foreground message: ${message.notification?.title} | ${message.notification?.body}');
      _showForegroundNotification(message);
    });

    // 4. Background message opened app listener (app was running in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM Notification tapped from background: ${message.data}');
      _handleNotificationClick(message);
    });

    // 5. Terminated state opened app check (app cold-started via notification tap)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('FCM Notification tapped from terminated state: ${initialMessage.data}');
      // Delay slightly to ensure widget tree & navigator are ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleNotificationClick(initialMessage);
      });
    }

    // 6. Listen for FCM token refresh and update Firestore
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && newToken.isNotEmpty) {
        saveUserToken(user.uid, token: newToken);
      }
    });
  }

  /// Requests notification permission on platforms that support it.
  Future<NotificationSettings> requestPermission() async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      debugPrint('FCM Permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      debugPrint('FCM requestPermission error: $e');
      return await FirebaseMessaging.instance.getNotificationSettings();
    }
  }

  /// Obtains the current device FCM token and stores it in the user's `users/{uid}`
  /// document within the `fcmTokens` array (using `FieldValue.arrayUnion`).
  Future<void> saveUserToken(String uid, {String? token}) async {
    try {
      final fcmToken = token ?? await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('FCM: No token received for user $uid');
        return;
      }

      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .set({
        'fcmTokens': FieldValue.arrayUnion([fcmToken]),
      }, SetOptions(merge: true));

      debugPrint('FCM: Token successfully registered for user $uid');
    } catch (e) {
      debugPrint('FCM saveUserToken error: $e');
    }
  }

  /// Removes the current device FCM token from the user's `fcmTokens` array on logout.
  Future<void> removeUserToken(String uid) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .update({
        'fcmTokens': FieldValue.arrayRemove([fcmToken]),
      });

      debugPrint('FCM: Token removed for user $uid');
    } catch (e) {
      debugPrint('FCM removeUserToken error: $e');
    }
  }

  /// Displays an in-app SnackBar when a message arrives while the app is in the foreground.
  void _showForegroundNotification(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Notification';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF111111),
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            const Icon(Icons.notifications_active_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      body,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () => _handleNotificationClick(message),
        ),
      ),
    );
  }

  /// Navigates the app to the relevant bookings screen/tab when a notification is tapped.
  Future<void> _handleNotificationClick(RemoteMessage message) async {
    final nav = navigatorKey.currentState;
    if (nav == null) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Determine user role from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(user.uid)
          .get();

      final role = userDoc.data()?['role'] as String? ?? 'seeker';
      final msgType = message.data['type'] as String?;

      if (role == 'provider') {
        // If it's a new request, open pending tab (index 0), else bookings tab (index 1)
        final targetIndex = (msgType == 'new_request') ? 0 : 1;
        nav.pushNamedAndRemoveUntil(
          '/providerDashboard',
          (route) => false,
          arguments: {'initialIndex': targetIndex},
        );
      } else {
        // Seeker bookings tab is index 1 on HomePage
        nav.pushNamedAndRemoveUntil(
          '/homePage',
          (route) => false,
          arguments: {'initialIndex': 1},
        );
      }
    } catch (e) {
      debugPrint('FCM _handleNotificationClick error: $e');
    }
  }
}
