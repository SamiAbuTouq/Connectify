import 'package:flutter/material.dart';
import 'transitions.dart';
import 'package:connectify/utils/responsive_utils.dart';
import 'package:connectify/theme.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final bool isActive;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.imagePath,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = Responsive(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final imageHeight = r.hp(28).clamp(160.0, 340.0);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      opacity: isActive ? 1.0 : 0.8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        transform: Matrix4.translationValues(0, isActive ? 0 : 20, 0),
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: r.horizontalPadding,
              vertical: r.hp(2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: r.hp(6)),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 600),
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: 0.8 + (0.2 * value),
                      child: Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(
                        color: theme.colorScheme.outline,
                        width: 1,
                      ),
                      boxShadow: isDark
                          ? AppShadows.darkMedium
                          : AppShadows.soft,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.xl - 1),
                      child: Image.asset(
                        imagePath,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: r.hp(4)),
                AnimatedSlideFade(
                  duration: const Duration(milliseconds: 600),
                  offset: const Offset(0, 30),
                  child: Text(
                    title,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontSize: r.sp(22),
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: r.hp(2)),
                AnimatedSlideFade(
                  duration: const Duration(milliseconds: 600),
                  offset: const Offset(0, 30),
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: r.sp(14),
                      height: 1.5,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Extra space at bottom so scrollable content is not occluded by the bottom dots & buttons
                SizedBox(height: r.hp(14)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
