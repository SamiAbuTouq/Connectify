import 'dart:math';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../models/service.dart';
import '../widgets/service_card.dart';
import '../widgets/bookings_list.dart';
import '../widgets/bookmarks_tab.dart';
import '../widgets/all_providers_tab.dart';
import 'select_provider_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/module/shared_data.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/widgets/circular_progress_indicator.dart';
import 'package:connectify/widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  final int? initialIndex;
  const HomePage({super.key, this.initialIndex});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _showingSubServices = false;
  String _selectedService = '';
  final Set<String> _selectedSubServices = {};

  final List<Service> _services = Service.sampleServices;
  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  String errorMessage = '';
  bool _initializedArgs = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialIndex != null) {
      _selectedIndex = widget.initialIndex!;
    }
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
        if (index != null && mounted) {
          setState(() {
            _selectedIndex = index;
          });
        }
      }
    }
  }

  void _handleServiceTap(Service service) {
    setState(() {
      _showingSubServices = true;
      _selectedService = service.name;
      _selectedSubServices.clear();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception('User not logged in.');
      final userData = await fetchUserData(userId);
      if (mounted) {
        setState(() {
          userProfile = userData;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  void _handleBack() {
    setState(() {
      _showingSubServices = false;
      _selectedService = '';
      _selectedSubServices.clear();
    });
  }

  void _handleSubServiceSelection(String subService) {
    setState(() {
      if (_selectedSubServices.contains(subService)) {
        _selectedSubServices.remove(subService);
      } else {
        _selectedSubServices.add(subService);
      }
    });
  }

  void _navigateToPaymentMethod() {
    final theme = Theme.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
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

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: _showingSubServices
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: _handleBack,
              )
            : null,
        title: Text(
          'Connectify',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: r.sp(20),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
      ),
      drawer: !_showingSubServices ? _buildDrawer() : null,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: r.contentMaxWidth),
          child: _showingSubServices
              ? _buildSubServicesContent(r)
              : _buildMainContent(r),
        ),
      ),
      bottomNavigationBar: !_showingSubServices ? _buildBottomAppBar() : null,
      floatingActionButton:
          _showingSubServices && _selectedSubServices.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _goToProviderSelection,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text('Continue (${_selectedSubServices.length})'),
                )
              : null,
    );
  }

  Widget _buildDrawer() {
    return AppDrawer(
      userProfile: userProfile,
      currentRoute: 'home',
      isProvider: false,
      onPaymentMethodTap: _navigateToPaymentMethod,
    );
  }

  Widget _buildBottomAppBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomAppBar(
      height: 64,
      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
      elevation: 8,
      shadowColor: Colors.black26,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(4, (index) {
          final bool isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      color: theme.colorScheme.primaryContainer,
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconForIndex(index, isSelected),
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    size: isSelected ? 24 : 22,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  IconData _getIconForIndex(int index, bool isSelected) {
    switch (index) {
      case 0:
        return isSelected ? Icons.home_rounded : Icons.home_outlined;
      case 1:
        return isSelected ? Icons.calendar_month_rounded : Icons.calendar_month_outlined;
      case 2:
        return isSelected ? Icons.bookmark_rounded : Icons.bookmark_border_rounded;
      case 3:
        return isSelected ? Icons.people_alt_rounded : Icons.people_outline_rounded;
      default:
        return Icons.error_outline_rounded;
    }
  }

  Widget _buildMainContent(Responsive r) {
    if (_showingSubServices) {
      return _buildSubServicesContent(r);
    }

    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent(r);
      case 1:
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        return BookingsList(role: 'seeker', uid: currentUid);
      case 2:
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        return BookmarksTab(uid: currentUid);
      case 3:
        final currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        return AllProvidersTab(uid: currentUid);
      default:
        return _buildHomeContent(r);
    }
  }

  Widget _buildSubServicesContent(Responsive r) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedServiceData =
        _services.firstWhere((service) => service.name == _selectedService);
    final subServices = selectedServiceData.subServices;
    final subServicesImg = selectedServiceData.subServicesImg;

    return FadeInUp(
      duration: const Duration(milliseconds: 250),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Select services:',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: r.sp(26),
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose what you need for $_selectedService',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: r.sp(14),
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: min(subServices.length, subServicesImg.length),
                padding: const EdgeInsets.only(bottom: 80),
                itemBuilder: (context, index) {
                  final isSelected =
                      _selectedSubServices.contains(subServices[index]);
                  return FadeInUp(
                    delay: Duration(milliseconds: 60 * index),
                    duration: const Duration(milliseconds: 250),
                    child: GestureDetector(
                      onTap: () {
                        _handleSubServiceSelection(subServices[index]);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                          color: isSelected
                              ? (isDark
                                  ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
                                  : theme.colorScheme.primaryContainer.withValues(alpha: 0.5))
                              : (isDark
                                  ? AppTheme.darkSurface
                                  : AppTheme.lightSurface),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark
                                    ? AppTheme.darkBorder
                                    : AppTheme.lightBorder),
                            width: isSelected ? 1.5 : 1,
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
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary.withValues(alpha: 0.15)
                                    : (isDark
                                        ? AppTheme.darkSurfaceVariant
                                        : AppTheme.primaryContainer.withValues(alpha: 0.7)),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                              child: Center(
                                child: Image.network(
                                  subServicesImg[index],
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                    Icons.miscellaneous_services_rounded,
                                    size: 24,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingMd),
                            Expanded(
                              child: Text(
                                subServices[index],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  fontSize: 15.5,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : (isDark
                                          ? AppTheme.darkBorder
                                          : theme.colorScheme.outlineVariant),
                                  width: 1.5,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToProviderSelection() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectProviderPage(
          mainService: _selectedService,
          subServices: _selectedSubServices.toList(),
        ),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent!'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _showingSubServices = false;
        _selectedService = '';
        _selectedSubServices.clear();
      });
    }
  }

  Widget _buildHomeContent(Responsive r) {
    final theme = Theme.of(context);
    return NestedScrollView(
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return [
          SliverToBoxAdapter(
            child: FadeInUp(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: r.horizontalPadding,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Text(
                      'Hello, ${(userProfile?['name'] ?? userProfile?['username'] ?? '').toString().split(' ')[0]}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: r.sp(16),
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'What service do you\nneed today?',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: r.sp(30),
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ];
      },
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding),
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            return FadeInUp(
              delay: Duration(milliseconds: 100 * index),
              duration: const Duration(milliseconds: 300),
              child: GestureDetector(
                onTap: () => _handleServiceTap(_services[index]),
                child: ServiceCard(service: _services[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    return _PaymentMethodsScreenState();
  }
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final List<String> _paymentMethods = [
    'Credit Card',
    'PayPal',
    'Google Pay',
    'Apple Pay',
    'Bank Transfer',
  ];

  String? _selectedPaymentMethod;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPaymentMethod();
  }

  Future<void> _loadSavedPaymentMethod() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final saved = doc.data()?['preferredPaymentMethod'] as String?;
          if (saved != null && _paymentMethods.contains(saved)) {
            if (mounted) {
              setState(() {
                _selectedPaymentMethod = saved;
              });
            }
          }
        }
      }
    } catch (e) {
      // Ignore or log error
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _savePaymentMethod() async {
    if (_selectedPaymentMethod == null || _isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'preferredPaymentMethod': _selectedPaymentMethod,
        }, SetOptions(merge: true));
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment method saved successfully'),
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save payment method: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);

    if (_isLoading) {
      return const SplachScreenLoader();
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: r.formMaxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: r.horizontalPadding,
            vertical: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select a Payment Method:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: r.sp(18),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _paymentMethods.length + 1, // +1 for the button
                itemBuilder: (context, index) {
                  if (index < _paymentMethods.length) {
                    return RadioListTile<String>(
                      title: Text(
                        _paymentMethods[index],
                        style: theme.textTheme.bodyMedium?.copyWith(fontSize: r.sp(15)),
                      ),
                      value: _paymentMethods[index],
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value;
                        });
                      },
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Center(
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: (_selectedPaymentMethod == null || _isSaving)
                                ? null
                                : _savePaymentMethod,
                            child: _isSaving
                                ? SplachScreenLoader(
                                    size: 20,
                                    strokeWidth: 2,
                                    color: theme.colorScheme.onPrimary,
                                  )
                                : Text(
                                    'Save',
                                    style: TextStyle(
                                      fontSize: r.sp(16),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
