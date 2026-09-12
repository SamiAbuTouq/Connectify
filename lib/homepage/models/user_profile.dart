import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/firestore_paths.dart';

/// Represents a document in the `users/{uid}` collection.
///
/// Fields
/// ------
/// - [role]        : `"provider"` or `"seeker"` — set during onboarding.
/// - [name]        : Display name chosen on the upload-photo screen.
/// - [email]       : From Firebase Auth at sign-up time.
/// - [phone]       : Optional — empty string if not provided.
/// - [imageUrl]    : Cloudinary URL uploaded during onboarding.
/// - [memberSince] : Human-readable join date (e.g. "September 2026").
/// - [createdAt]   : Server timestamp written on first document creation.
class UserProfile {
  final String id;
  final String role; // "provider" | "seeker"
  final String name;
  final String email;
  final String phone;
  final String imageUrl;
  final String memberSince;
  final DateTime? createdAt;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const UserProfile({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
    required this.memberSince,
    this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // Firestore ↔ Dart conversion
  // ---------------------------------------------------------------------------

  /// Deserialises a Firestore document snapshot into a [UserProfile].
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      id: doc.id,
      role: data['role'] as String? ?? 'seeker',
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      memberSince: data['memberSince'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Serialises this profile to a plain map suitable for `set()` / `update()`.
  ///
  /// Pass [includeCreatedAt] as `true` only on initial document creation so
  /// that subsequent updates do not overwrite the original server timestamp.
  Map<String, dynamic> toMap({bool includeCreatedAt = false}) {
    return <String, dynamic>{
      'role': role,
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'memberSince': memberSince,
      if (includeCreatedAt) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ---------------------------------------------------------------------------
  // Remote fetch
  // ---------------------------------------------------------------------------

  /// Fetches a [UserProfile] from Firestore by [userId].
  ///
  /// Returns [sampleProfile] on any error so callers never receive null.
  static Future<UserProfile> fetchProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserProfile.fromFirestore(doc);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching user profile: $e');
      return sampleProfile;
    }
  }

  // ---------------------------------------------------------------------------
  // Placeholder / fallback
  // ---------------------------------------------------------------------------

  static const UserProfile sampleProfile = UserProfile(
    id: 'sample',
    role: 'seeker',
    name: 'John Doe',
    email: 'john.doe@example.com',
    phone: '+1 234 567 8900',
    imageUrl: '',
    memberSince: 'January 2024',
    createdAt: null,
  );
}
