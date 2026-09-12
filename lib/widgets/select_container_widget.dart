import 'package:flutter/material.dart';
import 'package:connectify/theme.dart';
import 'package:connectify/utils/responsive_utils.dart';

class SelectContainerWidget extends StatelessWidget {
  final String title1;
  final String title2;
  final String img;
  final bool select;
  const SelectContainerWidget({
    super.key,
    required this.title1,
    required this.title2,
    required this.img,
    required this.select,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: r.hp(14).clamp(100.0, 150.0),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: r.wp(4).clamp(16.0, 24.0),
        vertical: r.hp(2).clamp(14.0, 20.0),
      ),
      decoration: BoxDecoration(
        color: select
            ? (isDark ? AppColors.grey900 : AppColors.grey100)
            : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: select
              ? theme.colorScheme.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: select ? 2.0 : 1.0,
        ),
        boxShadow: select
            ? (isDark ? AppShadows.darkSubtle : AppShadows.subtle)
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title1,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: r.sp(18),
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title2,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: r.sp(13),
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: select
                  ? (isDark ? AppColors.grey800 : AppColors.grey200)
                  : (isDark ? AppColors.darkSurfaceMuted : AppColors.grey100),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              img,
              width: r.sp(22).clamp(20.0, 26.0),
            ),
          ),
        ],
      ),
    );
  }
}
