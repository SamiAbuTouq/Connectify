import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/homepage/widgets/dialogs.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/services/theme_service.dart';
import 'package:connectify/widgets/theme_mode_selector.dart';

class AppDrawer extends StatelessWidget {
  final Map<String, dynamic>? userProfile;
  final String currentRoute;
  final bool isProvider;
  final VoidCallback? onHomeTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onPaymentMethodTap;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onHelpSupportTap;

  const AppDrawer({
    super.key,
    this.userProfile,
    this.currentRoute = 'home',
    this.isProvider = false,
    this.onHomeTap,
    this.onProfileTap,
    this.onPaymentMethodTap,
    this.onSettingsTap,
    this.onHelpSupportTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final r = Responsive(context);
    final drawerWidth = min(r.wp(78), 300.0).clamp(260.0, 300.0);

    // Resolve user data with comprehensive fallbacks
    final currentUser = FirebaseAuth.instance.currentUser;
    final rawName = userProfile?['name'] as String? ??
        userProfile?['username'] as String? ??
        currentUser?.displayName;
    final email = userProfile?['email'] as String? ?? currentUser?.email ?? '';
    final displayName = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (email.isNotEmpty && email.contains('@')
            ? email.split('@').first
            : 'Connectify User');

    final imageUrl = (userProfile?['imageUrl'] as String?)?.isNotEmpty == true
        ? userProfile!['imageUrl'] as String
        : ((userProfile?['photoURL'] as String?)?.isNotEmpty == true
            ? userProfile!['photoURL'] as String
            : currentUser?.photoURL);

    final role = isProvider
        ? 'Service Provider'
        : (userProfile?['role'] as String? ?? 'Customer');

    return Drawer(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      elevation: 0,
      width: drawerWidth,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // -----------------------------------------------------------------
            // Integrated Profile Section (No black block/banner)
            // -----------------------------------------------------------------
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  if (onProfileTap != null) {
                    onProfileTap!();
                  } else {
                    Navigator.pushNamed(context, '/profilePage');
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      // Avatar with neat border
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorderStrong : AppColors.lightBorderStrong,
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildDefaultAvatar(isDark),
                                )
                              : _buildDefaultAvatar(isDark),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),

                      // User Info (Name, Email, Role)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              displayName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15.5,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              role,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Subtle Divider under Profile Section
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),

            // -----------------------------------------------------------------
            // Menu Items List
            // -----------------------------------------------------------------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                children: [
                  // Home or Dashboard
                  _DrawerNavTile(
                    icon: isProvider ? Icons.dashboard_outlined : Icons.home_outlined,
                    selectedIcon: isProvider ? Icons.dashboard_rounded : Icons.home_rounded,
                    title: isProvider ? 'Dashboard' : 'Home',
                    isSelected: isProvider ? currentRoute == 'dashboard' : currentRoute == 'home',
                    onTap: () {
                      Navigator.pop(context);
                      if (onHomeTap != null) {
                        onHomeTap!();
                      }
                    },
                  ),

                  // Profile
                  _DrawerNavTile(
                    icon: Icons.person_outline_rounded,
                    selectedIcon: Icons.person_rounded,
                    title: 'Profile',
                    isSelected: currentRoute == 'profile',
                    onTap: () {
                      Navigator.pop(context);
                      if (onProfileTap != null) {
                        onProfileTap!();
                      } else {
                        Navigator.pushNamed(context, '/profilePage');
                      }
                    },
                  ),

                  // Payment Method
                  _DrawerNavTile(
                    icon: Icons.credit_card_outlined,
                    selectedIcon: Icons.credit_card_rounded,
                    title: 'Payment Method',
                    isSelected: currentRoute == 'payment',
                    onTap: () {
                      Navigator.pop(context);
                      if (onPaymentMethodTap != null) {
                        onPaymentMethodTap!();
                      }
                    },
                  ),

                  // Settings
                  _DrawerNavTile(
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    title: 'Settings',
                    isSelected: currentRoute == 'settings',
                    onTap: () {
                      Navigator.pop(context);
                      if (onSettingsTap != null) {
                        onSettingsTap!();
                      } else {
                        _showSettingsBottomSheet(context);
                      }
                    },
                  ),

                  // Help & Support
                  _DrawerNavTile(
                    icon: Icons.help_outline_rounded,
                    selectedIcon: Icons.help_rounded,
                    title: 'Help & Support',
                    isSelected: currentRoute == 'help',
                    onTap: () {
                      Navigator.pop(context);
                      if (onHelpSupportTap != null) {
                        onHelpSupportTap!();
                      } else {
                        Navigator.pushNamed(context, '/helpSupportPage');
                      }
                    },
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // Footer Section (Subtle Divider, Logout, App Info)
            // -----------------------------------------------------------------
            Divider(
              height: 1,
              thickness: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: _DrawerNavTile(
                icon: Icons.logout_rounded,
                selectedIcon: Icons.logout_rounded,
                title: 'Logout',
                isSelected: false,
                onTap: () {
                  Navigator.pop(context);
                  showLogoutDialog(context);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
                top: AppSpacing.xxs,
              ),
              child: Center(
                child: Text(
                  'Connectify • v1.0.0',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDefaultAvatar(bool isDark) {
    return Image.asset(
      AppAssets.defaultAvatar,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: isDark ? AppColors.darkSurfaceMuted : AppColors.grey100,
        child: Icon(
          Icons.person_rounded,
          size: 26,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeService.instance.themeModeNotifier,
          builder: (context, currentMode, _) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.xl),
                ),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.grey700 : AppColors.grey300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Settings',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Theme / Appearance Section
                      Text(
                        'APPEARANCE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Select app theme (System Default, Light, or Dark)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const ThemeModeSelector(),
                      const SizedBox(height: AppSpacing.md),

                      Divider(
                        height: 1,
                        thickness: 1,
                        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.notifications_none_rounded),
                        title: const Text('Notifications'),
                        subtitle: const Text('Push & email notifications enabled'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.privacy_tip_outlined),
                        title: const Text('Privacy & Terms'),
                        subtitle: const Text('Read Connectify user agreement'),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.info_outline_rounded),
                        title: const Text('About Connectify'),
                        subtitle: const Text('Version 1.0.0 (Build 100)'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _DrawerNavTile extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerNavTile({
    required this.icon,
    this.selectedIcon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final tileBg = isSelected
        ? (isDark ? AppColors.grey800 : AppColors.grey100)
        : Colors.transparent;

    final textColor = isSelected
        ? (isDark ? AppColors.pureWhite : AppColors.nearBlack)
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    final iconColor = isSelected
        ? (isDark ? AppColors.pureWhite : AppColors.nearBlack)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: tileBg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 12,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? (selectedIcon ?? icon) : icon,
                  size: 22,
                  color: iconColor,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14.5,
                      color: textColor,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.pureWhite : AppColors.nearBlack,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
