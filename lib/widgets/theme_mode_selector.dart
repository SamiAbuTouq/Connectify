import 'package:flutter/material.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/services/theme_service.dart';

/// Interactive segmented selector for choosing between System Default, Light, and Dark themes.
class ThemeModeSelector extends StatelessWidget {
  final bool compact;

  const ThemeModeSelector({
    super.key,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeModeNotifier,
      builder: (context, currentMode, _) {
        final options = [
          (
            mode: ThemeMode.system,
            label: 'System',
            icon: Icons.brightness_auto_rounded
          ),
          (
            mode: ThemeMode.light,
            label: 'Light',
            icon: Icons.light_mode_rounded
          ),
          (
            mode: ThemeMode.dark,
            label: 'Dark',
            icon: Icons.dark_mode_rounded
          ),
        ];

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.grey100,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xxs + 1),
          child: Row(
            children: options.map((option) {
              final isSelected = currentMode == option.mode;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    ThemeService.instance.setThemeMode(option.mode);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                      vertical: compact ? AppSpacing.xs + 2 : AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark ? AppColors.darkSurfaceMuted : AppColors.pureWhite)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: isDark
                                    ? const Color(0x33000000)
                                    : const Color(0x12000000),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                      border: isSelected
                          ? Border.all(
                              color: isDark
                                  ? AppColors.darkBorderStrong
                                  : AppColors.lightBorderStrong,
                              width: 1,
                            )
                          : Border.all(color: Colors.transparent, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          option.icon,
                          size: 16,
                          color: isSelected
                              ? (isDark ? AppColors.pureWhite : AppColors.nearBlack)
                              : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          option.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 13,
                            color: isSelected
                                ? (isDark ? AppColors.pureWhite : AppColors.nearBlack)
                                : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// Helper function to show a theme selection bottom sheet or dialog.
Future<void> showThemeSelectionDialog(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                'Select Theme',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose how Connectify looks on your device',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const ThemeModeSelector(),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      );
    },
  );
}
