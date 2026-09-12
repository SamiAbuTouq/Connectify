import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/firestore_paths.dart';

/// Represents a document in the `providers/{uid}` collection.
///
/// Every provider has both a [UserProfile] in `users/{uid}` (for basic info
/// visible to all users) and a [ProviderProfile] here (for service-specific
/// details).  The document id matches the user's Firebase Auth uid.
///
/// Fields
/// ------
/// - [uid]             : Same as the Firebase Auth uid and the document id.
/// - [mainService]     : Top-level service category (e.g. "Home Maintenance").
/// - [subServices]     : List of specific offerings under [mainService].
/// - [experienceLevel] : Selected experience range (e.g. "5 to 10 Year").
/// - [aboutMe]         : Free-text bio — mapped from `otherInfo` in onboarding.
/// - [rating]          : Running average rating; defaults to `0.0`.
/// - [ratingCount]     : Number of completed reviews; defaults to `0`.
/// - [isAvailable]     : Whether the provider is currently accepting jobs.
class ProviderProfile {
  final String uid;
  final String mainService;
  final List<String> subServices;
  final String experienceLevel;
  final String aboutMe;
  final double rating;
  final int ratingCount;
  final bool isAvailable;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const ProviderProfile({
    required this.uid,
    required this.mainService,
    required this.subServices,
    required this.experienceLevel,
    required this.aboutMe,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isAvailable = true,
  });

  // ---------------------------------------------------------------------------
  // Firestore ↔ Dart conversion
  // ---------------------------------------------------------------------------

  /// Deserialises a Firestore document snapshot into a [ProviderProfile].
  factory ProviderProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProviderProfile(
      uid: doc.id,
      mainService: data['mainService'] as String? ?? '',
      subServices: List<String>.from(
        (data['subServices'] as List<dynamic>?) ?? const [],
      ),
      experienceLevel: data['experienceLevel'] as String? ?? '',
      aboutMe: data['aboutMe'] as String? ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  /// Serialises this profile to a plain map suitable for `set()` / `update()`.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'mainService': mainService,
      'subServices': subServices,
      'experienceLevel': experienceLevel,
      'aboutMe': aboutMe,
      'rating': rating,
      'ratingCount': ratingCount,
      'isAvailable': isAvailable,
    };
  }

  // ---------------------------------------------------------------------------
  // Remote fetch
  // ---------------------------------------------------------------------------

  /// Fetches the [ProviderProfile] for [uid] from Firestore.
  ///
  /// Returns `null` when the document does not exist (e.g. the user is a
  /// seeker, not a provider).
  static Future<ProviderProfile?> fetchProfile(String uid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.providers)
          .doc(uid)
          .get();

      if (doc.exists) {
        return ProviderProfile.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching provider profile: $e');
      return null;
    }
  }

  /// Returns a stream that emits the [ProviderProfile] whenever it changes in
  /// Firestore — useful for real-time availability updates on listing screens.
  static Stream<ProviderProfile?> watchProfile(String uid) {
    return FirebaseFirestore.instance
        .collection(FirestorePaths.providers)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? ProviderProfile.fromFirestore(doc) : null);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns a copy of this profile with the given fields overridden.
  ProviderProfile copyWith({
    String? mainService,
    List<String>? subServices,
    String? experienceLevel,
    String? aboutMe,
    double? rating,
    int? ratingCount,
    bool? isAvailable,
  }) {
    return ProviderProfile(
      uid: uid,
      mainService: mainService ?? this.mainService,
      subServices: subServices ?? this.subServices,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      aboutMe: aboutMe ?? this.aboutMe,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
