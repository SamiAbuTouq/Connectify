import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/firestore_paths.dart';

// ---------------------------------------------------------------------------
// Status enum
// ---------------------------------------------------------------------------

/// All possible states of a service request.
enum ServiceRequestStatus {
  /// Created by seeker, awaiting provider response.
  pending,

  /// Provider has agreed to perform the service.
  accepted,

  /// Provider declined the request.
  rejected,

  /// Service has been delivered and the job is closed.
  completed,

  /// Seeker or provider cancelled before completion.
  cancelled;

  // ── Serialisation ──────────────────────────────────────────────────────────

  /// The string value stored in Firestore.
  String get value => name; // enum name matches Firestore value 1-to-1

  /// Parses a Firestore string back to the enum.
  ///
  /// Falls back to [pending] for any unknown value so the app never crashes
  /// on unexpected data.
  static ServiceRequestStatus fromValue(String? raw) {
    return ServiceRequestStatus.values.firstWhere(
      (s) => s.value == raw,
      orElse: () => ServiceRequestStatus.pending,
    );
  }
}

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Represents a document in the `serviceRequests/{requestId}` collection.
///
/// Fields
/// ------
/// - [id]          : Firestore document id (auto-generated).
/// - [seekerId]    : uid of the user who created the request.
/// - [providerId]  : uid of the provider the request is directed at.
/// - [mainService] : Top-level service category.
/// - [subServices] : Specific sub-services requested.
/// - [status]      : Current lifecycle state of the request.
/// - [scheduledAt] : Optional agreed appointment time.
/// - [createdAt]   : Server timestamp of document creation.
/// - [updatedAt]   : Server timestamp of last status change.
class ServiceRequest {
  final String id;
  final String seekerId;
  final String providerId;
  final String mainService;
  final List<String> subServices;
  final ServiceRequestStatus status;
  final DateTime? scheduledAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const ServiceRequest({
    required this.id,
    required this.seekerId,
    required this.providerId,
    required this.mainService,
    required this.subServices,
    required this.status,
    this.scheduledAt,
    this.createdAt,
    this.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // Firestore ↔ Dart conversion
  // ---------------------------------------------------------------------------

  /// Deserialises a Firestore document snapshot into a [ServiceRequest].
  factory ServiceRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ServiceRequest(
      id: doc.id,
      seekerId: data['seekerId'] as String? ?? '',
      providerId: data['providerId'] as String? ?? '',
      mainService: data['mainService'] as String? ?? '',
      subServices: List<String>.from(
        (data['subServices'] as List<dynamic>?) ?? const [],
      ),
      status: ServiceRequestStatus.fromValue(data['status'] as String?),
      scheduledAt: (data['scheduledAt'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Serialises this request to a plain map suitable for `set()` / `update()`.
  ///
  /// On **creation**, both [createdAt] and [updatedAt] are set to server
  /// timestamp. On **updates** (e.g. status change) only [updatedAt] is
  /// refreshed — pass `isCreate: false` in that case.
  Map<String, dynamic> toMap({bool isCreate = false}) {
    return <String, dynamic>{
      'seekerId': seekerId,
      'providerId': providerId,
      'mainService': mainService,
      'subServices': subServices,
      'status': status.value,
      'scheduledAt':
          scheduledAt != null ? Timestamp.fromDate(scheduledAt!) : null,
      if (isCreate) 'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // ---------------------------------------------------------------------------
  // Remote fetch
  // ---------------------------------------------------------------------------

  /// Fetches a single [ServiceRequest] by [requestId].
  ///
  /// Returns `null` if the document does not exist.
  static Future<ServiceRequest?> fetchRequest(String requestId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.serviceRequests)
          .doc(requestId)
          .get();

      if (doc.exists) {
        return ServiceRequest.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching service request: $e');
      return null;
    }
  }

  /// Returns a real-time stream of all requests where [uid] is the seeker.
  static Stream<List<ServiceRequest>> watchAsSeekerStream(String uid) {
    return FirebaseFirestore.instance
        .collection(FirestorePaths.serviceRequests)
        .where('seekerId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) {
            final list =
                snapshot.docs.map(ServiceRequest.fromFirestore).toList();
            list.sort((a, b) {
              final tA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final tB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return tB.compareTo(tA);
            });
            return list;
          },
        );
  }

  /// Returns a real-time stream of all requests where [uid] is the provider.
  static Stream<List<ServiceRequest>> watchAsProviderStream(String uid) {
    return FirebaseFirestore.instance
        .collection(FirestorePaths.serviceRequests)
        .where('providerId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) {
            final list =
                snapshot.docs.map(ServiceRequest.fromFirestore).toList();
            list.sort((a, b) {
              final tA = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              final tB = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
              return tB.compareTo(tA);
            });
            return list;
          },
        );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Returns a copy of this request with the given fields overridden.
  ServiceRequest copyWith({
    ServiceRequestStatus? status,
    DateTime? scheduledAt,
  }) {
    return ServiceRequest(
      id: id,
      seekerId: seekerId,
      providerId: providerId,
      mainService: mainService,
      subServices: subServices,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
