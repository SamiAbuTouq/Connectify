import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/widgets/circular_progress_indicator.dart';

/// A shared bookings list widget used by both Seekers (in HomePage)
/// and Providers (in ProviderDashboardPage).
class BookingsList extends StatefulWidget {
  final String role; // 'seeker' or 'provider'
  final String uid;
  final bool excludePending;

  const BookingsList({
    super.key,
    required this.role,
    required this.uid,
    this.excludePending = false,
  });

  @override
  State<BookingsList> createState() => _BookingsListState();
}

class _BookingsListState extends State<BookingsList> {
  // In-memory cache for user profile lookups (other party)
  final Map<String, Map<String, dynamic>> _userCache = {};

  Future<Map<String, dynamic>> _getOtherPartyData(String otherPartyUid) async {
    if (otherPartyUid.isEmpty) return {};
    if (_userCache.containsKey(otherPartyUid)) {
      return _userCache[otherPartyUid]!;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherPartyUid)
          .get();
      final data = doc.data() ?? {};
      _userCache[otherPartyUid] = data;
      return data;
    } catch (e) {
      debugPrint('BookingsList: error fetching user data: $e');
      return {};
    }
  }

  Future<void> _markCompleted(String requestId) async {
    try {
      await FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(requestId)
          .update({
        'status': 'completed',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking marked as completed!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('BookingsList: error marking completed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e'),
          ),
        );
      }
    }
  }

  String _ratingDescription(int rating) {
    switch (rating) {
      case 1:
        return '1 - Poor';
      case 2:
        return '2 - Fair';
      case 3:
        return '3 - Good';
      case 4:
        return '4 - Very Good';
      case 5:
        return '5 - Excellent!';
      default:
        return '$rating Stars';
    }
  }

  Future<void> _submitReview({
    required String requestId,
    required String providerId,
    required String seekerId,
    required int rating,
    required String comment,
  }) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Fetch all reviews for this provider to compute aggregate
    final reviewsSnapshot = await firestore
        .collection('reviews')
        .where('providerId', isEqualTo: providerId)
        .get();

    final reviewDocRef = firestore.collection('reviews').doc();
    final providerDocRef = firestore.collection('providers').doc(providerId);

    await firestore.runTransaction((transaction) async {
      final providerDoc = await transaction.get(providerDocRef);

      // Collect existing ratings (excluding any review for this requestId to avoid duplicate count)
      final ratings = reviewsSnapshot.docs
          .where((d) => (d.data()['requestId'] as String?) != requestId)
          .map((d) => (d.data()['rating'] as num?)?.toDouble() ?? 0.0)
          .where((r) => r > 0)
          .toList();

      ratings.add(rating.toDouble());

      final newCount = ratings.length;
      final newAvg = ratings.reduce((a, b) => a + b) / newCount;

      transaction.set(reviewDocRef, {
        'requestId': requestId,
        'providerId': providerId,
        'seekerId': seekerId,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (providerDoc.exists) {
        transaction.update(providerDocRef, {
          'rating': double.parse(newAvg.toStringAsFixed(2)),
          'ratingCount': newCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        transaction.set(
          providerDocRef,
          {
            'rating': double.parse(newAvg.toStringAsFixed(2)),
            'ratingCount': newCount,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  void _showRatingDialog({
    required BuildContext context,
    required String requestId,
    required String providerId,
    required String seekerId,
    required String providerName,
  }) {
    int selectedRating = 5;
    final commentController = TextEditingController();
    bool isSubmitting = false;
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: theme.colorScheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              title: Text(
                'Rate $providerName',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'How was your experience with this service?',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 1-5 Star Picker (Monochrome)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        return IconButton(
                          iconSize: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            starValue <= selectedRating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: starValue <= selectedRating
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = starValue;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _ratingDescription(selectedRating),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Comment field
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Share more details (optional)...',
                        hintStyle: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: theme.colorScheme.primary),
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed:
                      isSubmitting ? null : () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await _submitReview(
                              requestId: requestId,
                              providerId: providerId,
                              seekerId: seekerId,
                              rating: selectedRating,
                              comment: commentController.text.trim(),
                            );
                            if (dialogCtx.mounted) {
                              Navigator.pop(dialogCtx);
                            }
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Thank you for your feedback!'),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Failed to submit review: $e'),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                  ),
                  child: isSubmitting
                      ? SplachScreenLoader(
                          size: 16,
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReviewSection({
    required String requestId,
    required String providerId,
    required String providerName,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('reviews')
          .where('requestId', isEqualTo: requestId)
          .limit(1)
          .snapshots(),
      builder: (context, reviewSnap) {
        final docs = reviewSnap.data?.docs ?? [];
        if (docs.isNotEmpty) {
          final reviewData = docs.first.data();
          final rating = (reviewData['rating'] as num?)?.toInt() ?? 5;
          final comment = reviewData['comment'] as String? ?? '';

          return Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Your Rating: ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ...List.generate(5, (i) {
                      return Icon(
                        i < rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: i < rating
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                      );
                    }),
                    const SizedBox(width: 4),
                    Text(
                      '($rating/5)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (comment.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    '"$comment"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(top: 12),
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showRatingDialog(
              context: context,
              requestId: requestId,
              providerId: providerId,
              seekerId: widget.uid,
              providerName: providerName,
            ),
            icon: Icon(Icons.star_rate_rounded,
                color: theme.colorScheme.primary, size: 18),
            label: Text(
              'Rate this provider',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        );
      },
    );
  }

  Color _statusColor(String status, BuildContext context) {
    final theme = Theme.of(context);
    switch (status.toLowerCase()) {
      case 'pending':
        return theme.colorScheme.onSurfaceVariant;
      case 'accepted':
        return theme.colorScheme.primary;
      case 'completed':
        return theme.colorScheme.onSurface;
      case 'rejected':
      case 'cancelled':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  Color _statusBgColor(String status, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    switch (status.toLowerCase()) {
      case 'pending':
        return isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant;
      case 'accepted':
        return theme.colorScheme.primaryContainer;
      case 'completed':
        return isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant;
      case 'rejected':
      case 'cancelled':
        return theme.colorScheme.errorContainer.withValues(alpha: 0.3);
      default:
        return isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant;
    }
  }

  void _showBookingDetails({
    required BuildContext context,
    required String requestId,
    required Map<String, dynamic> data,
    required Map<String, dynamic> otherPartyData,
    required DateTime? scheduledAt,
    required DateTime? createdAt,
    required bool canMarkCompleted,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final status = (data['status'] as String? ?? 'pending').toLowerCase();
    final mainService = data['mainService'] as String? ?? '';
    final subServices = (data['subServices'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final otherPartyName =
        (otherPartyData['name'] as String?)?.trim().isNotEmpty == true
            ? otherPartyData['name'] as String
            : (otherPartyData['username'] as String? ??
                (widget.role == 'seeker' ? 'Provider' : 'Seeker'));
    final otherPartyAvatar = otherPartyData['imageUrl'] as String? ?? '';
    final otherPartyEmail = otherPartyData['email'] as String? ?? '';

    final dateFormat = DateFormat('EEEE, MMMM d, yyyy • h:mm a');
    final formattedScheduled =
        scheduledAt != null ? dateFormat.format(scheduledAt) : 'Not specified';
    final formattedCreated =
        createdAt != null ? dateFormat.format(createdAt) : 'Recently';

    final color = _statusColor(status, context);
    final bgColor = _statusBgColor(status, context);
    final capitalizedStatus =
        status.isNotEmpty ? '${status[0].toUpperCase()}${status.substring(1)}' : '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header with Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Booking Details',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: color.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          capitalizedStatus,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Other party card
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          backgroundImage: otherPartyAvatar.isNotEmpty
                              ? NetworkImage(otherPartyAvatar) as ImageProvider
                              : const AssetImage(AppAssets.defaultAvatar),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.role == 'seeker' ? 'Provider' : 'Seeker',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                otherPartyName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (otherPartyEmail.isNotEmpty)
                                Text(
                                  otherPartyEmail,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Service info
                  Text(
                    'Service Category',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mainService,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (subServices.isNotEmpty) ...[
                    Text(
                      'Requested Sub-Services',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: subServices.map((sub) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSurfaceVariant
                                : AppTheme.lightSurfaceVariant,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(
                              color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                            ),
                          ),
                          child: Text(
                            sub,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Schedule info
                  Text(
                    'Scheduled Date & Time',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 18, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          formattedScheduled,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Timestamps
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(
                        color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Request ID',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              requestId.substring(
                                  0, requestId.length > 8 ? 8 : requestId.length),
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Requested On',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              formattedCreated,
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Rating section for seeker when booking is completed
                  if (widget.role == 'seeker' && status == 'completed') ...[
                    const SizedBox(height: 16),
                    _buildReviewSection(
                      requestId: requestId,
                      providerId: data['providerId'] as String? ?? '',
                      providerName: otherPartyName,
                    ),
                  ],

                  // Actions
                  if (canMarkCompleted) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(bottomSheetCtx);
                          _markCompleted(requestId);
                        },
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                        label: const Text(
                          'Mark as Completed',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(bottomSheetCtx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.uid.isEmpty) {
      return const AppEmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Sign in Required',
        subtitle: 'Please sign in to view your bookings.',
      );
    }

    final queryField = widget.role == 'seeker' ? 'seekerId' : 'providerId';

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('serviceRequests')
            .where(queryField, isEqualTo: widget.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplachScreenLoader();
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: 'Error loading bookings: ${snapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          var docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
              snapshot.data?.docs ?? []);

          // Sort descending by createdAt in memory
          docs.sort((a, b) {
            final aCreated = a.data()['createdAt'];
            final bCreated = b.data()['createdAt'];
            final aTime = aCreated is Timestamp
                ? aCreated.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = bCreated is Timestamp
                ? bCreated.toDate()
                : DateTime.fromMillisecondsSinceEpoch(0);
            return bTime.compareTo(aTime);
          });

          if (widget.excludePending) {
            docs = docs
                .where((d) => (d.data()['status'] ?? 'pending') != 'pending')
                .toList();
          }

          if (docs.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: AppEmptyState(
                    icon: Icons.event_note_outlined,
                    title: 'No bookings found',
                    subtitle: widget.role == 'seeker'
                        ? 'You haven\'t booked any services yet.\nExplore services on the Home tab to get started!'
                        : 'No bookings match this category.',
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final requestId = doc.id;

              final otherPartyUid = widget.role == 'seeker'
                  ? (data['providerId'] as String? ?? '')
                  : (data['seekerId'] as String? ?? '');

              final mainService = data['mainService'] as String? ?? '';
              final subServices = (data['subServices'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList() ??
                  [];
              final status = (data['status'] as String? ?? 'pending').toLowerCase();
              final scheduledTimestamp = data['scheduledAt'] as Timestamp?;
              final scheduledAt = scheduledTimestamp?.toDate();
              final createdTimestamp = data['createdAt'] as Timestamp?;
              final createdAt = createdTimestamp?.toDate();

              final canMarkCompleted =
                  widget.role == 'provider' && status == 'accepted';

              final dateFormat = DateFormat('EEE, MMM d, yyyy • h:mm a');
              final formattedScheduled = scheduledAt != null
                  ? dateFormat.format(scheduledAt)
                  : 'Not specified';

              final color = _statusColor(status, context);
              final bgColor = _statusBgColor(status, context);
              final capitalizedStatus = status.isNotEmpty
                  ? '${status[0].toUpperCase()}${status.substring(1)}'
                  : '';

              return FadeInUp(
                delay: Duration(milliseconds: 50 * index),
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _getOtherPartyData(otherPartyUid),
                  builder: (context, userSnapshot) {
                    final otherPartyData = userSnapshot.data ?? {};
                    final otherPartyName = (otherPartyData['name'] as String?)
                                ?.trim()
                                .isNotEmpty ==
                            true
                        ? otherPartyData['name'] as String
                        : (otherPartyData['username'] as String? ??
                            (widget.role == 'seeker' ? 'Provider' : 'Seeker'));
                    final otherPartyAvatar =
                        otherPartyData['imageUrl'] as String? ?? '';

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black26
                                : Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: InkWell(
                        onTap: () => _showBookingDetails(
                          context: context,
                          requestId: requestId,
                          data: data,
                          otherPartyData: otherPartyData,
                          scheduledAt: scheduledAt,
                          createdAt: createdAt,
                          canMarkCompleted: canMarkCompleted,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacingMd),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top Row: Other party avatar + name + status badge
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundColor: theme.colorScheme.primaryContainer,
                                    backgroundImage: otherPartyAvatar.isNotEmpty
                                        ? NetworkImage(otherPartyAvatar) as ImageProvider
                                        : const AssetImage(AppAssets.defaultAvatar),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          otherPartyName,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          mainService,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Status chip
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                      border: Border.all(
                                          color: color.withValues(alpha: 0.3)),
                                    ),
                                    child: Text(
                                      capitalizedStatus,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Divider(height: 1),
                              ),

                              // Sub-services preview
                              if (subServices.isNotEmpty) ...[
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: subServices.map((sub) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isDark
                                            ? AppTheme.darkSurfaceVariant
                                            : AppTheme.lightSurfaceVariant,
                                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                      ),
                                      child: Text(
                                        sub,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark
                                              ? AppTheme.darkTextPrimary
                                              : AppTheme.lightTextPrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Scheduled Date/Time
                              Row(
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      size: 15, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    formattedScheduled,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.chevron_right_rounded,
                                      size: 20, color: theme.colorScheme.onSurfaceVariant),
                                ],
                              ),

                              // Seeker rating section for completed bookings
                              if (widget.role == 'seeker' &&
                                  status == 'completed') ...[
                                _buildReviewSection(
                                  requestId: requestId,
                                  providerId: otherPartyUid,
                                  providerName: otherPartyName,
                                ),
                              ],

                              // Optional Mark Completed button for provider
                              if (canMarkCompleted) ...[
                                const SizedBox(height: 14),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _markCompleted(requestId),
                                    icon: const Icon(Icons.check_circle_outline_rounded,
                                        size: 18),
                                    label: const Text(
                                      'Mark as Completed',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
