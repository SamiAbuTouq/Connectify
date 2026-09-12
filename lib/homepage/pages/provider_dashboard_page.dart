import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:animate_do/animate_do.dart';
import 'package:connectify/module/shared_data.dart';
import 'package:connectify/homepage/pages/home_page.dart'
    show PaymentMethodsScreen;
import 'package:connectify/homepage/widgets/bookings_list.dart';
import 'package:connectify/widgets/circular_progress_indicator.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/widgets/app_drawer.dart';

class ProviderDashboardPage extends StatefulWidget {
  final int? initialIndex;
  const ProviderDashboardPage({super.key, this.initialIndex});

  @override
  State<ProviderDashboardPage> createState() => _ProviderDashboardPageState();
}

class _ProviderDashboardPageState extends State<ProviderDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  bool _initializedArgs = false;

  // In-memory cache for fetched seeker profiles to minimize Firestore reads.
  final Map<String, Map<String, dynamic>> _seekerCache = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: (widget.initialIndex != null && widget.initialIndex! < 2)
          ? widget.initialIndex!
          : 0,
    );
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedArgs) {
      _initializedArgs = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('initialIndex')) {
        final index = args['initialIndex'] as int?;
        if (index != null && index < 2 && mounted) {
          _tabController.animateTo(index);
        }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (uid.isEmpty) throw Exception('User not logged in.');
      final data = await fetchUserData(uid);
      if (mounted) {
        setState(() {
          userProfile = data;
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<Map<String, dynamic>> _getSeekerData(String seekerId) async {
    if (_seekerCache.containsKey(seekerId)) {
      return _seekerCache[seekerId]!;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(seekerId)
          .get();
      final data = doc.data() ?? {};
      _seekerCache[seekerId] = data;
      return data;
    } catch (e) {
      debugPrint('Error fetching seeker data: $e');
      return {};
    }
  }

  Future<void> _updateRequestStatus(
    String requestId,
    String status, {
    required String successMessage,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('serviceRequests')
          .doc(requestId)
          .update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating request status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update request: $e'),
          ),
        );
      }
    }
  }

  void _navigateToPaymentMethod() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Payment Methods',
            ),
          ),
          body: const PaymentMethodsScreen(),
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return AppDrawer(
      userProfile: userProfile,
      currentRoute: 'dashboard',
      isProvider: true,
      onPaymentMethodTap: _navigateToPaymentMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Provider Dashboard',
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: r.sp(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          labelStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: r.sp(14),
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: r.sp(14),
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.pending_actions_rounded),
              text: 'Pending Requests',
            ),
            Tab(
              icon: Icon(Icons.event_note_rounded),
              text: 'Bookings',
            ),
          ],
        ),
      ),
      drawer: _buildDrawer(),
      body: currentUid.isEmpty
          ? const AppEmptyState(
              icon: Icons.lock_outline_rounded,
              title: 'Sign in Required',
              subtitle: 'Please sign in to view your provider dashboard.',
            )
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('serviceRequests')
                  .where('providerId', isEqualTo: currentUid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SplachScreenLoader();
                }

                if (snapshot.hasError) {
                  return AppErrorState(
                    message: 'Error loading requests: ${snapshot.error}',
                    onRetry: () => setState(() {}),
                  );
                }

                final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
                    snapshot.data?.docs ?? []);

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

                final pendingDocs = docs
                    .where((d) => (d.data()['status'] ?? 'pending') == 'pending')
                    .toList();

                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPendingTab(pendingDocs, r),
                        BookingsList(
                          role: 'provider',
                          uid: currentUid,
                          excludePending: true,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Pending Requests Tab
  // ────────────────────────────────────────────────────────────────────────────

  Widget _buildPendingTab(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, Responsive r) {
    if (docs.isEmpty) {
      return const AppEmptyState(
        icon: Icons.inbox_rounded,
        title: 'No pending requests',
        subtitle: 'New booking requests from seekers will appear here in real time.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: r.wp(4).clamp(16.0, 24.0),
        vertical: AppTheme.spacingMd,
      ),
      itemCount: docs.length,
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data();
        final requestId = doc.id;

        final seekerId = data['seekerId'] as String? ?? '';
        final mainService = data['mainService'] as String? ?? '';
        final subServices = (data['subServices'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
        final scheduledTimestamp = data['scheduledAt'] as Timestamp?;
        final scheduledAt = scheduledTimestamp?.toDate();

        return FadeInUp(
          delay: Duration(milliseconds: 60 * index),
          child: _PendingRequestCard(
            requestId: requestId,
            seekerId: seekerId,
            mainService: mainService,
            subServices: subServices,
            scheduledAt: scheduledAt,
            seekerDataFuture: _getSeekerData(seekerId),
            r: r,
            onAccept: () => _updateRequestStatus(
              requestId,
              'accepted',
              successMessage: 'Request accepted!',
            ),
            onReject: () => _updateRequestStatus(
              requestId,
              'rejected',
              successMessage: 'Request rejected.',
            ),
          ),
        );
      },
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Pending Request Card
// ──────────────────────────────────────────────────────────────────────────────

class _PendingRequestCard extends StatelessWidget {
  final String requestId;
  final String seekerId;
  final String mainService;
  final List<String> subServices;
  final DateTime? scheduledAt;
  final Future<Map<String, dynamic>> seekerDataFuture;
  final Responsive r;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _PendingRequestCard({
    required this.requestId,
    required this.seekerId,
    required this.mainService,
    required this.subServices,
    required this.scheduledAt,
    required this.seekerDataFuture,
    required this.r,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dateFormat = DateFormat('EEE, MMM d, yyyy • h:mm a');
    final formattedDate =
        scheduledAt != null ? dateFormat.format(scheduledAt!) : 'Not specified';

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
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
          // Seeker Header
          FutureBuilder<Map<String, dynamic>>(
            future: seekerDataFuture,
            builder: (context, snapshot) {
              final userData = snapshot.data ?? {};
              final seekerName =
                  (userData['name'] as String?)?.trim().isNotEmpty == true
                      ? userData['name'] as String
                      : (userData['username'] as String? ?? 'Seeker');
              final seekerAvatar = userData['imageUrl'] as String? ?? '';

              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: seekerAvatar.isNotEmpty
                        ? NetworkImage(seekerAvatar) as ImageProvider
                        : const AssetImage(AppAssets.defaultAvatar),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seekerName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: r.sp(15),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          mainService,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: r.sp(13),
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Text(
                      'Pending',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: r.sp(12),
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // Sub-Services
          if (subServices.isNotEmpty) ...[
            Text(
              'Requested Services:',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: subServices.map((service) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: Text(
                    service,
                    style: TextStyle(
                      fontSize: r.sp(12),
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Scheduled Date/Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkSurfaceVariant : AppTheme.lightSurfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time_rounded,
                    size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: r.sp(13),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons (Reject / Accept)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: r.sp(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: r.sp(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
