import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/widgets/circular_progress_indicator.dart';
import '../widgets/favorite_button.dart';

/// A data class holding everything we need to display for one provider.
class _ProviderInfo {
  final String uid;
  final String name;
  final String imageUrl;
  final double rating;
  final int ratingCount;
  final String experienceLevel;

  const _ProviderInfo({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.ratingCount,
    required this.experienceLevel,
  });
}

/// Navigates from sub-service selection to provider list → date/time → confirm.
///
/// Constructor arguments:
///   [mainService]  – the top-level service category string (e.g. "Home Maintenance")
///   [subServices]  – the sub-services the seeker selected (e.g. ["Electrician"])
class SelectProviderPage extends StatefulWidget {
  final String mainService;
  final List<String> subServices;

  const SelectProviderPage({
    super.key,
    required this.mainService,
    required this.subServices,
  });

  @override
  State<SelectProviderPage> createState() => _SelectProviderPageState();
}

class _SelectProviderPageState extends State<SelectProviderPage> {
  late final Future<List<_ProviderInfo>> _providersFuture;

  @override
  void initState() {
    super.initState();
    _providersFuture = _fetchProviders();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Data layer
  // ────────────────────────────────────────────────────────────────────────────

  /// Queries `providers` with the three Firestore filters, then enriches each
  /// result with the display name and avatar from the `users` collection.
  Future<List<_ProviderInfo>> _fetchProviders() async {
    final firestore = FirebaseFirestore.instance;

    // Firestore `array-contains-any` supports up to 10 values.
    final subServicesQuery = widget.subServices.take(10).toList();

    final snapshot = await firestore
        .collection('providers')
        .where('mainService', isEqualTo: widget.mainService)
        .where('subServices', arrayContainsAny: subServicesQuery)
        .where('isAvailable', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) return [];

    // Enrich each provider doc with user profile data in parallel.
    final futures = snapshot.docs.map((providerDoc) async {
      final data = providerDoc.data();
      final uid = providerDoc.id;

      // Fetch the matching user document for name / avatar.
      final userDoc =
          await firestore.collection('users').doc(uid).get();
      final userData = userDoc.data() ?? {};

      return _ProviderInfo(
        uid: uid,
        name: (userData['name'] as String?)?.trim().isNotEmpty == true
            ? userData['name'] as String
            : (userData['username'] as String? ?? 'Unknown'),
        imageUrl: userData['imageUrl'] as String? ?? '',
        rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
        ratingCount: (data['ratingCount'] as num?)?.toInt() ?? 0,
        experienceLevel: data['experienceLevel'] as String? ?? '',
      );
    });

    return Future.wait(futures);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Flow: tap provider → date → time → confirm dialog → Firestore write
  // ────────────────────────────────────────────────────────────────────────────

  Future<void> _onProviderTapped(_ProviderInfo provider) async {
    // 1. Date picker
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (!mounted || pickedDate == null) return;

    // 2. Time picker
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

    // 3. Confirm dialog
    await _showConfirmDialog(provider, scheduledAt);
  }

  Future<void> _showConfirmDialog(
      _ProviderInfo provider, DateTime scheduledAt) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        final dialogTheme = Theme.of(dialogCtx);
        return AlertDialog(
          backgroundColor: dialogTheme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: Text(
            'Confirm Booking',
            style: dialogTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You are about to request the following services:',
                style: dialogTheme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              ...widget.subServices.map((s) => Text(
                    '• $s',
                    style: dialogTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  )),
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
                    '  ${_fmt2(scheduledAt.hour)}:${_fmt2(scheduledAt.minute)}',
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

    await _submitRequest(provider, scheduledAt);
  }

  Future<void> _submitRequest(
      _ProviderInfo provider, DateTime scheduledAt) async {
    final seekerId = FirebaseAuth.instance.currentUser?.uid;
    if (seekerId == null) {
      _showSnack('Error: you are not signed in.', isError: true);
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('serviceRequests').add({
        'seekerId': seekerId,
        'providerId': provider.uid,
        'mainService': widget.mainService,
        'subServices': widget.subServices,
        'status': 'pending',
        'scheduledAt': Timestamp.fromDate(scheduledAt),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      // Pop back to the home page (pops SelectProviderPage).
      Navigator.of(context).pop(true);
    } catch (e) {
      debugPrint('_submitRequest: error — $e');
      if (mounted) {
        _showSnack('Failed to send request. Please try again.', isError: true);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────────

  String _fmt2(int v) => v.toString().padLeft(2, '0');

  String _starLabel(double rating, int count) {
    final rounded = rating.toStringAsFixed(1);
    return '$rounded ★ ($count review${count == 1 ? '' : 's'})';
  }

  // ────────────────────────────────────────────────────────────────────────────
  // UI
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a Provider',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.mainService,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<_ProviderInfo>>(
        future: _providersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplachScreenLoader();
          }

          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }

          final providers = snapshot.data ?? [];
          if (providers.isEmpty) return _buildEmptyState();

          return _buildProviderList(providers);
        },
      ),
    );
  }

  Widget _buildProviderList(List<_ProviderInfo> providers) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingMd,
      ),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        return FadeInUp(
          delay: Duration(milliseconds: 80 * index),
          child: _ProviderCard(
            provider: providers[index],
            starLabel: _starLabel(
                providers[index].rating, providers[index].ratingCount),
            onTap: () => _onProviderTapped(providers[index]),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: 'No providers available',
      subtitle: 'There are currently no available providers for the selected services. Please try again later or choose different sub-services.',
      action: OutlinedButton.icon(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded),
        label: const Text('Go Back'),
      ),
    );
  }

  Widget _buildError(String error) {
    return AppErrorState(
      message: error,
      onRetry: () => setState(() {
        _providersFuture = _fetchProviders();
      }),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Provider card widget — styled after ServiceCard
// ──────────────────────────────────────────────────────────────────────────────

class _ProviderCard extends StatelessWidget {
  final _ProviderInfo provider;
  final String starLabel;
  final VoidCallback onTap;

  const _ProviderCard({
    required this.provider,
    required this.starLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
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
                  const SizedBox(height: 4),
                  Text(
                    starLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (provider.experienceLevel.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      ),
                      child: Text(
                        provider.experienceLevel,
                        style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            FavoriteButton(
              providerId: provider.uid,
              size: 22,
              activeColor: theme.colorScheme.primary,
              inactiveColor: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(width: 8),

            Icon(Icons.arrow_forward_ios_rounded,
                color: theme.colorScheme.onSurface, size: 14),
          ],
        ),
      ),
    );
  }
}
