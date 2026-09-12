import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animate_do/animate_do.dart';
import 'package:connectify/services/firestore_paths.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/widgets/circular_progress_indicator.dart';
import 'favorite_button.dart';

/// Data model representing an enriched Provider profile for seeker browsing.
class ProviderItem {
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

  const ProviderItem({
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

enum ProviderSortOption {
  highestRating,
  mostReviews,
  nameAZ,
}

/// The All Providers tab widget for Provider Requesters (Seekers).
///
/// Features:
/// - Real-time stream of providers from Firestore
/// - Enriched user profile details (cached for performance)
/// - Search bar with instant keyword matching
/// - Category pill filter (dynamically resolved)
/// - Availability toggle filter
/// - Sort options (Rating, Reviews, Name)
/// - Bookmark / Favorite integration
/// - Complete Booking flow (Service selection -> Date -> Time -> Confirm -> Write)
/// - Provider detail modal sheet
class AllProvidersTab extends StatefulWidget {
  final String uid;

  const AllProvidersTab({
    super.key,
    required this.uid,
  });

  @override
  State<AllProvidersTab> createState() => _AllProvidersTabState();
}

class _AllProvidersTabState extends State<AllProvidersTab> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, Map<String, dynamic>> _userProfileCache = {};

  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _onlyAvailable = false;
  ProviderSortOption _sortOption = ProviderSortOption.highestRating;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final query = _searchController.text.trim().toLowerCase();
      if (_searchQuery != query) {
        setState(() {
          _searchQuery = query;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserProfile(String uid) async {
    if (_userProfileCache.containsKey(uid)) {
      return _userProfileCache[uid]!;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection(FirestorePaths.users)
          .doc(uid)
          .get();
      final data = doc.data() ?? {};
      _userProfileCache[uid] = data;
      return data;
    } catch (e) {
      debugPrint('Error fetching user profile for $uid: $e');
      return {};
    }
  }

  List<ProviderItem> _filterAndSortProviders(List<ProviderItem> providers) {
    return providers.where((p) {
      // 1. Availability filter
      if (_onlyAvailable && !p.isAvailable) {
        return false;
      }

      // 2. Category filter
      if (_selectedCategory != 'All' &&
          p.mainService.toLowerCase() != _selectedCategory.toLowerCase()) {
        return false;
      }

      // 3. Search query filter
      if (_searchQuery.isNotEmpty) {
        final matchesName = p.name.toLowerCase().contains(_searchQuery);
        final matchesCategory =
            p.mainService.toLowerCase().contains(_searchQuery);
        final matchesSub = p.subServices
            .any((sub) => sub.toLowerCase().contains(_searchQuery));
        final matchesAbout = p.aboutMe.toLowerCase().contains(_searchQuery);
        final matchesExp =
            p.experienceLevel.toLowerCase().contains(_searchQuery);

        if (!matchesName &&
            !matchesCategory &&
            !matchesSub &&
            !matchesAbout &&
            !matchesExp) {
          return false;
        }
      }

      return true;
    }).toList()
      ..sort((a, b) {
        switch (_sortOption) {
          case ProviderSortOption.highestRating:
            final cmp = b.rating.compareTo(a.rating);
            if (cmp != 0) return cmp;
            return b.ratingCount.compareTo(a.ratingCount);
          case ProviderSortOption.mostReviews:
            final cmp = b.ratingCount.compareTo(a.ratingCount);
            if (cmp != 0) return cmp;
            return b.rating.compareTo(a.rating);
          case ProviderSortOption.nameAZ:
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
      });
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Booking Flow
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _startBookingFlow(ProviderItem provider) async {
    final subServices = provider.subServices;
    List<String> selectedSubServices = [];
    final theme = Theme.of(context);

    if (subServices.isNotEmpty) {
      // 1. Select specific sub-services
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
              return SafeArea(
                child: Padding(
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
                        'Select the service(s) you need:',
                        style: modalTheme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.35,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: subServices.length,
                          itemBuilder: (context, idx) {
                            final item = subServices[idx];
                            final isChecked = tempSelected.contains(item);
                            return CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(item,
                                  style: modalTheme.textTheme.bodyMedium),
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
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusMd),
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
          title: Text('Confirm Booking Request',
              style: dialogTheme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('You are about to request the following services:',
                  style: dialogTheme.textTheme.bodyMedium),
              const SizedBox(height: 10),
              ...selectedSubServices.map((s) => Text('• $s',
                  style: dialogTheme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w500))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person_rounded,
                      size: 16, color: dialogTheme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    provider.name,
                    style: dialogTheme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
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
                style:
                    TextStyle(color: dialogTheme.colorScheme.onSurfaceVariant),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Send Request'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    // 5. Submit to Firestore
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
        SnackBar(
          content: Text('Request sent to ${provider.name} successfully!'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      debugPrint('AllProvidersTab: error submitting request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
          ),
        );
      }
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Provider Detail Sheet
  // ────────────────────────────────────────────────────────────────────────────

  void _showProviderDetailsSheet(ProviderItem provider) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.92,
          expand: false,
          builder: (sheetContext, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header with avatar & info
                  Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurfaceVariant
                              : AppTheme.lightSurfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          child: provider.imageUrl.isNotEmpty
                              ? Image.network(
                                  provider.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider.name,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              provider.mainService,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 16,
                                    color: theme.colorScheme.onSurface),
                                const SizedBox(width: 4),
                                Text(
                                  '${provider.rating.toStringAsFixed(1)} (${provider.ratingCount} reviews)',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      FavoriteButton(
                        providerId: provider.uid,
                        currentUid: widget.uid,
                        size: 26,
                        activeColor: theme.colorScheme.primary,
                        inactiveColor: theme.colorScheme.outlineVariant,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Availability Status Banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: provider.isAvailable
                          ? (isDark
                              ? AppTheme.darkSurfaceVariant
                              : AppTheme.lightSurfaceVariant)
                          : (isDark ? Colors.black38 : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color:
                            isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: provider.isAvailable
                                ? (isDark ? Colors.white : Colors.black)
                                : theme.colorScheme.outline,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          provider.isAvailable
                              ? 'Currently Available for Bookings'
                              : 'Currently Unavailable',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (provider.experienceLevel.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Experience',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      provider.experienceLevel,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],

                  if (provider.aboutMe.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'About Provider',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      provider.aboutMe,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.4,
                      ),
                    ),
                  ],

                  if (provider.subServices.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Services Offered',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.subServices.map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppTheme.darkSurfaceVariant
                                : AppTheme.lightSurfaceVariant,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusSm),
                            border: Border.all(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder,
                            ),
                          ),
                          child: Text(
                            service,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Book Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _startBookingFlow(provider);
                      },
                      icon: const Icon(Icons.calendar_month_rounded, size: 18),
                      label: const Text(
                        'Book This Provider',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
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
  }

  // ────────────────────────────────────────────────────────────────────────────
  // UI Builder
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection(FirestorePaths.providers)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SplachScreenLoader(message: 'Loading providers...');
        }

        if (snapshot.hasError) {
          return AppErrorState(
            message: 'Error loading providers: ${snapshot.error}',
            onRetry: () => setState(() {}),
          );
        }

        final providerDocs = snapshot.data?.docs ?? [];

        if (providerDocs.isEmpty) {
          return const AppEmptyState(
            icon: Icons.people_outline_rounded,
            title: 'No Providers Available',
            subtitle:
                'There are currently no registered service providers in the platform.',
          );
        }

        // Distinct categories for horizontal chips
        final categories = <String>{'All'};
        for (final doc in providerDocs) {
          final ms = (doc.data()['mainService'] as String?)?.trim();
          if (ms != null && ms.isNotEmpty) {
            categories.add(ms);
          }
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _userProfileCache.clear();
            });
            await Future.delayed(const Duration(milliseconds: 400));
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Search & Filter Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: r.horizontalPadding,
                    vertical: 12.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurfaceVariant
                              : AppTheme.lightSurfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.darkBorder
                                : AppTheme.lightBorder,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText:
                                'Search providers, services, skills...',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded,
                                        size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Category Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categories.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(cat),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _selectedCategory = cat;
                                    });
                                  }
                                },
                                labelStyle: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? theme.colorScheme.onPrimary
                                      : theme.colorScheme.onSurface,
                                ),
                                selectedColor: theme.colorScheme.primary,
                                backgroundColor: isDark
                                    ? AppTheme.darkSurfaceVariant
                                    : AppTheme.lightSurfaceVariant,
                                side: BorderSide(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : (isDark
                                          ? AppTheme.darkBorder
                                          : AppTheme.lightBorder),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppTheme.radiusFull),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary Controls (Availability + Sort)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Availability filter chip
                          FilterChip(
                            label: const Text('Available Now'),
                            selected: _onlyAvailable,
                            onSelected: (val) {
                              setState(() {
                                _onlyAvailable = val;
                              });
                            },
                            avatar: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _onlyAvailable
                                    ? (isDark ? Colors.white : Colors.black)
                                    : theme.colorScheme.outline,
                              ),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: _onlyAvailable
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: _onlyAvailable
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurface,
                            ),
                            selectedColor: theme.colorScheme.primary,
                            backgroundColor: isDark
                                ? AppTheme.darkSurfaceVariant
                                : AppTheme.lightSurfaceVariant,
                            side: BorderSide(
                              color: _onlyAvailable
                                  ? theme.colorScheme.primary
                                  : (isDark
                                      ? AppTheme.darkBorder
                                      : AppTheme.lightBorder),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                            ),
                          ),

                          // Sort Dropdown
                          PopupMenuButton<ProviderSortOption>(
                            initialValue: _sortOption,
                            onSelected: (opt) {
                              setState(() {
                                _sortOption = opt;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.darkBorder
                                      : AppTheme.lightBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.sort_rounded,
                                      size: 16,
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                  const SizedBox(width: 4),
                                  Text(
                                    _sortOptionLabel(_sortOption),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(Icons.arrow_drop_down_rounded,
                                      size: 18,
                                      color:
                                          theme.colorScheme.onSurfaceVariant),
                                ],
                              ),
                            ),
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: ProviderSortOption.highestRating,
                                child: Text('Highest Rating'),
                              ),
                              const PopupMenuItem(
                                value: ProviderSortOption.mostReviews,
                                child: Text('Most Reviews'),
                              ),
                              const PopupMenuItem(
                                value: ProviderSortOption.nameAZ,
                                child: Text('Name (A-Z)'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Provider List Items
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.horizontalPadding,
                  vertical: 8.0,
                ),
                sliver: FutureBuilder<List<ProviderItem>>(
                  future: _resolveAllProviders(providerDocs),
                  builder: (context, resolvedSnapshot) {
                    if (resolvedSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        !resolvedSnapshot.hasData) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 40.0),
                          child: SplachScreenLoader(size: 28),
                        ),
                      );
                    }

                    final allProviders = resolvedSnapshot.data ?? [];
                    final filteredProviders =
                        _filterAndSortProviders(allProviders);

                    if (filteredProviders.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: AppEmptyState(
                            icon: Icons.search_off_rounded,
                            title: 'No Providers Found',
                            subtitle:
                                'No service providers match your active search and filter criteria.',
                            action: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  _selectedCategory = 'All';
                                  _onlyAvailable = false;
                                });
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Reset Filters'),
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final provider = filteredProviders[index];
                          return FadeInUp(
                            delay: Duration(
                                milliseconds: min(60 * index, 600)),
                            child: _ProviderCard(
                              provider: provider,
                              currentUid: widget.uid,
                              onTap: () =>
                                  _showProviderDetailsSheet(provider),
                              onBook: () => _startBookingFlow(provider),
                            ),
                          );
                        },
                        childCount: filteredProviders.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<List<ProviderItem>> _resolveAllProviders(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    final futures = docs.map((doc) async {
      final pData = doc.data();
      final uid = doc.id;
      final uData = await _fetchUserProfile(uid);

      final name = (uData['name'] as String?)?.trim().isNotEmpty == true
          ? uData['name'] as String
          : (uData['username'] as String? ?? 'Service Provider');

      return ProviderItem(
        uid: uid,
        name: name,
        imageUrl: uData['imageUrl'] as String? ?? '',
        email: uData['email'] as String? ?? '',
        mainService: pData['mainService'] as String? ?? 'General Service',
        subServices: List<String>.from(
          (pData['subServices'] as List<dynamic>?) ?? const [],
        ),
        experienceLevel: pData['experienceLevel'] as String? ?? '',
        aboutMe: pData['aboutMe'] as String? ?? '',
        rating: (pData['rating'] as num?)?.toDouble() ?? 0.0,
        ratingCount: (pData['ratingCount'] as num?)?.toInt() ?? 0,
        isAvailable: pData['isAvailable'] as bool? ?? true,
      );
    });

    return Future.wait(futures);
  }

  String _sortOptionLabel(ProviderSortOption opt) {
    switch (opt) {
      case ProviderSortOption.highestRating:
        return 'Rating';
      case ProviderSortOption.mostReviews:
        return 'Reviews';
      case ProviderSortOption.nameAZ:
        return 'A-Z';
    }
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Provider Card Widget
// ──────────────────────────────────────────────────────────────────────────────

class _ProviderCard extends StatelessWidget {
  final ProviderItem provider;
  final String currentUid;
  final VoidCallback onTap;
  final VoidCallback onBook;

  const _ProviderCard({
    required this.provider,
    required this.currentUid,
    required this.onTap,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
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
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Avatar, Name, Category, Heart Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkSurfaceVariant
                          : AppTheme.lightSurfaceVariant,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color:
                            isDark ? AppTheme.darkBorder : AppTheme.lightBorder,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd),
                      child: provider.imageUrl.isNotEmpty
                          ? Image.network(
                              provider.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Image.asset(
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

                  // Name & Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                provider.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (provider.isAvailable)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                          ],
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
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                size: 15,
                                color: theme.colorScheme.onSurface),
                            const SizedBox(width: 3),
                            Text(
                              '${provider.rating.toStringAsFixed(1)} ★ (${provider.ratingCount})',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (provider.experienceLevel.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text('•',
                                  style: TextStyle(
                                      color:
                                          theme.colorScheme.onSurfaceVariant)),
                              const SizedBox(width: 8),
                              Text(
                                provider.experienceLevel,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Favorite Button
                  FavoriteButton(
                    providerId: provider.uid,
                    currentUid: currentUid,
                    size: 22,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor: theme.colorScheme.outlineVariant,
                  ),
                ],
              ),

              // Sub-services Chips (if available)
              if (provider.subServices.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...provider.subServices.take(3).map((sub) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSurfaceVariant
                              : AppTheme.lightSurfaceVariant,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                          border: Border.all(
                              color: isDark
                                  ? AppTheme.darkBorder
                                  : AppTheme.lightBorder),
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
                    if (provider.subServices.length > 3)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          '+${provider.subServices.length - 3} more',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: const Text('View Profile',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onBook,
                      icon: const Icon(Icons.calendar_month_rounded, size: 16),
                      label: const Text(
                        'Book Now',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
