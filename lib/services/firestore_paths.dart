/// Centralised Firestore collection and document path strings.
///
/// Use these constants instead of raw string literals throughout the app so
/// that a collection rename is always a single-line change here, not a
/// grep-and-replace across the entire codebase.
///
/// Usage example:
/// ```dart
/// FirebaseFirestore.instance
///     .collection(FirestorePaths.users)
///     .doc(uid)
///     .set(data);
/// ```
abstract final class FirestorePaths {
  // ── Top-level collections ─────────────────────────────────────────────────

  /// `users/{uid}` — basic profile visible to every authenticated user.
  static const String users = 'users';

  /// `providers/{uid}` — extended provider profile; same id as the user doc.
  static const String providers = 'providers';

  /// `serviceRequests/{requestId}` — requests created by seekers.
  static const String serviceRequests = 'serviceRequests';

  /// `reviews/{reviewId}` — ratings left by seekers after job completion.
  static const String reviews = 'reviews';

  /// `favorites/{uid}` — root document for a seeker's bookmarks.
  static const String favorites = 'favorites';

  // ── Subcollection names ───────────────────────────────────────────────────

  /// `favorites/{uid}/providers/{providerId}` — marker subcollection.
  static const String favoritedProviders = 'providers';

  // ── Helper path builders ──────────────────────────────────────────────────

  /// Full path to a single user document: `users/{uid}`.
  static String userDoc(String uid) => '$users/$uid';

  /// Full path to a single provider document: `providers/{uid}`.
  static String providerDoc(String uid) => '$providers/$uid';

  /// Full path to a single service-request document.
  static String serviceRequestDoc(String requestId) =>
      '$serviceRequests/$requestId';

  /// Full path to a single review document.
  static String reviewDoc(String reviewId) => '$reviews/$reviewId';

  /// Full path to the providers sub-collection inside a seeker's favourites.
  /// e.g. `favorites/{uid}/providers`.
  static String favoritedProvidersCol(String seekerUid) =>
      '$favorites/$seekerUid/$favoritedProviders';

  /// Full path to a single favourited-provider marker document.
  static String favoritedProviderDoc(String seekerUid, String providerUid) =>
      '${favoritedProvidersCol(seekerUid)}/$providerUid';
}
