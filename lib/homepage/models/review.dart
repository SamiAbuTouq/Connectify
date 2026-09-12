import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/firestore_paths.dart';

/// Represents a document in the `reviews/{reviewId}` collection.
///
/// A review is created by a seeker after a [ServiceRequest] reaches
/// `completed` status.  There is at most one review per request.
///
/// Fields
/// ------
/// - [id]         : Firestore document id (auto-generated).
/// - [requestId]  : The `serviceRequests/{requestId}` this review belongs to.
/// - [providerId] : uid of the provider being reviewed.
/// - [seekerId]   : uid of the seeker who wrote the review.
/// - [rating]     : Integer score from 1 (poor) to 5 (excellent).
/// - [comment]    : Optional free-text feedback.
/// - [createdAt]  : Server timestamp of document creation.
class Review {
  final String id;
  final String requestId;
  final String providerId;
  final String seekerId;
  final int rating; // 1 – 5
  final String comment;
  final DateTime? createdAt;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const Review({
    required this.id,
    required this.requestId,
    required this.providerId,
    required this.seekerId,
    required this.rating,
    required this.comment,
    this.createdAt,
  }) : assert(rating >= 1 && rating <= 5, 'rating must be between 1 and 5');

  // ---------------------------------------------------------------------------
  // Firestore ↔ Dart conversion
  // ---------------------------------------------------------------------------

  /// Deserialises a Firestore document snapshot into a [Review].
  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      requestId: data['requestId'] as String? ?? '',
      providerId: data['providerId'] as String? ?? '',
      seekerId: data['seekerId'] as String? ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 1,
      comment: data['comment'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Serialises this review to a plain map suitable for `add()` / `set()`.
  ///
  /// [createdAt] is always a server timestamp so the value is canonical.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'requestId': requestId,
      'providerId': providerId,
      'seekerId': seekerId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // ---------------------------------------------------------------------------
  // Remote fetch
  // ---------------------------------------------------------------------------

  /// Fetches all [Review]s for [providerId], ordered newest-first.
  static Future<List<Review>> fetchForProvider(String providerId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestorePaths.reviews)
          .where('providerId', isEqualTo: providerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map(Review.fromFirestore).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching reviews for provider $providerId: $e');
      return const [];
    }
  }

  /// Returns a real-time stream of reviews for [providerId].
  static Stream<List<Review>> watchForProvider(String providerId) {
    return FirebaseFirestore.instance
        .collection(FirestorePaths.reviews)
        .where('providerId', isEqualTo: providerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map(Review.fromFirestore).toList(),
        );
  }

  /// Fetches the single [Review] linked to [requestId], or `null` if it
  /// doesn't exist yet (i.e. the seeker hasn't left one yet).
  static Future<Review?> fetchForRequest(String requestId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(FirestorePaths.reviews)
          .where('requestId', isEqualTo: requestId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return Review.fromFirestore(snapshot.docs.first);
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching review for request $requestId: $e');
      return null;
    }
  }
}
