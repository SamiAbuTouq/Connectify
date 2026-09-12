import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:connectify/services/notification_service.dart';

/// Temporary in-memory store shared across the multi-step onboarding flow.
/// Keys written by each screen:
///   signup / Google sign-in : 'email'
///   upload_img              : 'imageUrl', 'username'
///   im_looking_for_screen   : 'provider'  ('true' | 'false')
///   experience              : 'experience', 'otherInfo'   (provider only)
///   select_service_page     : 'mainService'               (provider only)
///   select_service_1_N      : 'subServices'               (provider only)
final Map<String, dynamic> sharedData = {};

/// Writes the onboarding data collected in [sharedData] to Firestore.
///
/// Always writes a `users/{uid}` document:
///   role, name, email, imageUrl, memberSince, createdAt
///
/// Additionally writes a `providers/{uid}` document when role == "provider":
///   mainService, subServices, experienceLevel, aboutMe,
///   rating: 0, ratingCount: 0, isAvailable: true
///
/// Both writes are committed in a single [WriteBatch] for atomicity.
/// On failure a [SnackBar] is shown via [context] and navigation does NOT
/// proceed (the caller is expected to only navigate after this Future
/// completes without throwing).
Future<void> storeUserInfo(BuildContext context) async {
  // Read the current user at call time — NOT at module load time, because the
  // top-level evaluation runs before sign-in completes.
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error: no authenticated user found. Please sign in again.'),
      ),
    );
    return;
  }

  final uid = user.uid;
  final isProvider = sharedData['provider'] == 'true';
  final now = DateTime.now();

  try {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();

    // ── users/{uid} ──────────────────────────────────────────────────────────
    final userDoc = firestore.collection('users').doc(uid);
    batch.set(userDoc, {
      'role': isProvider ? 'provider' : 'seeker',
      'name': sharedData['username'] ?? user.displayName ?? '',
      'email': sharedData['email'] ?? user.email ?? '',
      'imageUrl': sharedData['imageUrl'] ?? '',
      'memberSince': now.toIso8601String(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // ── providers/{uid} ──────────────────────────────────────────────────────
    if (isProvider) {
      final providerDoc = firestore.collection('providers').doc(uid);
      batch.set(providerDoc, {
        'mainService': sharedData['mainService'] ?? '',
        'subServices': sharedData['subServices'] ?? [],
        'experienceLevel': sharedData['experience'] ?? '',
        'aboutMe': sharedData['otherInfo'] ?? '',
        'rating': 0,
        'ratingCount': 0,
        'isAvailable': true,
      });
    }

    await batch.commit();

    // Register FCM token for push notifications
    await NotificationService.instance.saveUserToken(uid);

    // Clear in-memory store after a successful write so stale data
    // cannot bleed into a subsequent onboarding session.
    sharedData.clear();

    debugPrint('storeUserInfo: Firestore write succeeded for uid=$uid '
        '(role: ${isProvider ? "provider" : "seeker"})');
  } catch (e) {
    debugPrint('storeUserInfo: Firestore write failed — $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save your profile. Please try again.\n$e'),
        ),
      );
    }
    // Re-throw so callers can guard their navigation.
    rethrow;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Utility read helpers (unchanged public API)
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches a user's profile document from the `users` collection.
Future<Map<String, dynamic>> fetchUserData(String userId) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    if (snapshot.exists) {
      return snapshot.data() as Map<String, dynamic>;
    }
    return {};
  } catch (e) {
    debugPrint('fetchUserData: error — $e');
    return {};
  }
}

/// Fetches all documents from the `services` collection.
Future<List<Map<String, dynamic>>> fetchServicesData() async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('services').get();
    return snapshot.docs
        .map((doc) => doc.data())
        .toList();
  } catch (e) {
    debugPrint('fetchServicesData: error — $e');
    return [];
  }
}
