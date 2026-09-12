import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:connectify/services/firestore_paths.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/widgets/circular_progress_indicator.dart';
import 'favorite_button.dart';

/// A data model representing the resolved provider details for bookmarks.
class _BookmarkedProviderData {
  final String uid;
  final String name;
  final String imageUrl;
  final String email;
  final String mainService;
  final List<String> subServices;
  final String experienceLevel;
  final String aboutMe;
  final double rating;
  final int ratingCount;
  final bool isAvailable;

  const _BookmarkedProviderData({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.email,
    required this.mainService,
    required this.subServices,
    required this.experienceLevel,
    required this.aboutMe,
    required this.rating,
    required this.ratingCount,
    required this.isAvailable,
  });
}

/// The Bookmarks tab widget for Seekers.
///
/// Listens to `favorites/{currentUid}/providers` in real-time,
/// fetches provider and user profile data, and allows quick booking.
class BookmarksTab extends StatefulWidget {
  final String uid;

  const BookmarksTab({
    super.key,
    required this.uid,
  });

  @override
  State<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends State<BookmarksTab> {
  // In-memory cache for provider details to avoid redundant reads
  final Map<String, _BookmarkedProviderData?> _providerCache = {};

  Future<_BookmarkedProviderData?> _fetchProviderDetails(
      String providerId) async {
    if (_providerCache.containsKey(providerId)) {
      return _providerCache[providerId];
    }

    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch provider profile and user profile in parallel
      final providerDocFuture = firestore
          .collection(FirestorePaths.providers)
          .doc(providerId)
          .get();
      final userDocFuture = firestore
          .collection(FirestorePaths.users)
          .doc(providerId)
          .get();

      final results = await Future.wait([providerDocFuture, userDocFuture]);
      final providerDoc = results[0];
      final userDoc = results[1];

      if (!providerDoc.exists && !userDoc.exists) {
        _providerCache[providerId] = null;
        return null;
      }

      final providerData = providerDoc.data() ?? {};
      final userData = userDoc.data() ?? {};

      final name = (userData['name'] as String?)?.trim().isNotEmpty == true
          ? userData['name'] as String
          : (userData['username'] as String? ?? 'Service Provider');

      final provider = _BookmarkedProviderData(
        uid: providerId,
        name: name,
        imageUrl: userData['imageUrl'] as String? ?? '',
        email: userData['email'] as String? ?? '',
        mainService: providerData['mainService'] as String? ?? 'General Service',
        subServices: List<String>.from(
          (providerData['subServices'] as List<dynamic>?) ?? const [],
        ),
        experienceLevel: providerData['experienceLevel'] as String? ?? '',
        aboutMe: providerData['aboutMe'] as String? ?? '',
        rating: (providerData['rating'] as num?)?.toDouble() ?? 0.0,
        ratingCount: (providerData['ratingCount'] as num?)?.toInt() ?? 0,
        isAvailable: providerData['isAvailable'] as bool? ?? true,
      );

      _providerCache[providerId] = provider;
      return provider;
    } catch (e) {
      debugPrint('BookmarksTab: error fetching provider $providerId: $e');
      return null;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Booking Flow for Bookmarked Provider
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _startBookingFlow(_BookmarkedProviderData provider) async {
    final subServices = provider.subServices;
    List<String> selectedSubServices = [];
    final theme = Theme.of(context);

    if (subServices.isNotEmpty) {
      // 1. Let seeker select from the provider's sub-services
      final pickedSubServices = await showModalBottomSheet<List<String>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: theme.colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) {
          final tempSelected = Set<String>.from(subServices);
          final modalTheme = Theme.of(sheetContext);
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: modalTheme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Book ${provider.name}',
                      style: modalTheme.textTheme.titleMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Category: ${provider.mainService}',
                      style: modalTheme.textTheme.bodyMedium?.copyWith(
                        color: modalTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Select services you need:',
                      style: modalTheme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.4,
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: subServices.length,
                        itemBuilder: (context, idx) {
                          final item = subServices[idx];
                          final isChecked = tempSelected.contains(item);
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(item, style: modalTheme.textTheme.bodyMedium),
                            value: isChecked,
                            onChanged: (val) {
                              setModalState(() {
                                if (val == true) {
                                  tempSelected.add(item);
                                } else {
                                  if (tempSelected.length > 1) {
                                    tempSelected.remove(item);
                                  }
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: tempSelected.isEmpty
                            ? null
                            : () => Navigator.pop(
                                context, tempSelected.toList()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                        ),
                        child: const Text(
                          'Continue to Date & Time',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );

      if (pickedSubServices == null || pickedSubServices.isEmpty) return;
      selectedSubServices = pickedSubServices;
    } else {
      selectedSubServices = [provider.mainService];
    }

    if (!mounted) return;

    // 2. Date picker
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (!mounted || pickedDate == null) return;

    // 3. Time picker
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (!mounted || pickedTime == null) return;

    final scheduledAt = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // 4. Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final dialogTheme = Theme.of(dialogCtx);
        return AlertDialog(
          backgroundColor: dialogTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Text('Confirm Booking', style: dialogTheme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are about to request the following services:', style: dialogTheme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              ...selectedSubServices.map((s) => Text('• $s', style: dialogTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_rounded, size: 16, color: dialogTheme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    provider.name,
                    style: dialogTheme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 16, color: dialogTheme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year}'
                    '  ${scheduledAt.hour.toString().padLeft(2, '0')}:${scheduledAt.minute.toString().padLeft(2, '0')}',
                    style: dialogTheme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(color: dialogTheme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    // 5. Submit request to Firestore
    try {
      await FirebaseFirestore.instance
          .collection(FirestorePaths.serviceRequests)
          .add({
        'seekerId': widget.uid,
        'providerId': provider.uid,
        'mainService': provider.mainService,
        'subServices': selectedSubServices,
        'status': 'pending',
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking request sent successfully!'),
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('BookmarksTab: error submitting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
          ),
        );
      }
    }
  }

  String _starLabel(double rating, int count) {
    final rounded = rating.toStringAsFixed(1);
    return '$rounded ★ ($count review${count == 1 ? '' : 's'})';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (widget.uid.isEmpty) {
      return const AppEmptyState(
        icon: Icons.lock_outline_rounded,
        title: 'Sign in Required',
        subtitle: 'Please sign in to view your bookmarks.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Clear in-memory cache on manual refresh
        setState(() {
          _providerCache.clear();
        });
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection(FirestorePaths.favorites)
            .doc(widget.uid)
            .collection(FirestorePaths.favoritedProviders)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplachScreenLoader();
          }

          if (snapshot.hasError) {
            return AppErrorState(
              message: 'Error loading bookmarks: ${snapshot.error}',
              onRetry: () => setState(() {}),
            );
          }

          final favDocs = snapshot.data?.docs ?? [];

          if (favDocs.isEmpty) {
            return LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints:
                      BoxConstraints(minHeight: constraints.maxHeight),
                  child: const AppEmptyState(
                    icon: Icons.bookmark_outline_rounded,
                    title: "You haven't bookmarked any providers yet",
                    subtitle: 'Save your favorite service providers to quickly book them anytime.',
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
            itemCount: favDocs.length,
            itemBuilder: (context, index) {
              final providerId = favDocs[index].id;

              return FadeInUp(
                delay: Duration(milliseconds: 60 * index),
                child: FutureBuilder<_BookmarkedProviderData?>(
                  future: _fetchProviderDetails(providerId),
                  builder: (context, providerSnapshot) {
                    if (providerSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !_providerCache.containsKey(providerId)) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                        child: const SplachScreenLoader(size: 24),
                      );
                    }

                    final provider = providerSnapshot.data;
                    if (provider == null) {
                      return const SizedBox();
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                      padding: const EdgeInsets.all(AppTheme.spacingMd),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                        border: Border.all(
                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Avatar, Name, Category & Heart Button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Avatar
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  border: Border.all(
                                    color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                  child: provider.imageUrl.isNotEmpty
                                      ? Image.network(
                                          provider.imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Image.asset(
                                            AppAssets.defaultAvatar,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          AppAssets.defaultAvatar,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      provider.mainService,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: 13,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _starLabel(provider.rating,
                                          provider.ratingCount),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Un-bookmark / Heart toggle
                              FavoriteButton(
                                providerId: provider.uid,
                                currentUid: widget.uid,
                                size: 24,
                                activeColor: theme.colorScheme.primary,
                                inactiveColor: theme.colorScheme.outlineVariant,
                              ),
                            ],
                          ),

                          // Badges & Sub-services
                          if (provider.experienceLevel.isNotEmpty ||
                              provider.subServices.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: [
                                if (provider.experienceLevel.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                      border: Border.all(
                                          color: theme.colorScheme.outlineVariant),
                                    ),
                                    child: Text(
                                      provider.experienceLevel,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ...provider.subServices.map((sub) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? AppTheme.darkSurfaceVariant
                                          : AppTheme.lightSurfaceVariant,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                      border: Border.all(
                                          color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
                                    ),
                                    child: Text(
                                      sub,
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ],

                          const SizedBox(height: 14),

                          // Book Now button (jump straight into booking flow)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _startBookingFlow(provider),
                              icon: const Icon(Icons.calendar_month_rounded,
                                  size: 18),
                              label: const Text(
                                'Book Now',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                ),
                              ),
                            ),
                          ),
                        ],
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
