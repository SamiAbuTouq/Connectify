import 'dart:math';
import 'package:flutter/material.dart';

/// Lightweight responsive helpers built on top of [MediaQuery].
///
/// Usage:
/// ```dart
/// final r = Responsive(context);
/// Padding(padding: EdgeInsets.symmetric(horizontal: r.horizontalPadding));
/// SizedBox(height: r.hp(10)); // 10 % of screen height
/// Text('Hello', style: TextStyle(fontSize: r.sp(16)));
/// ```
class Responsive {
  final double width;
  final double height;

  Responsive(BuildContext context)
      : width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height;

  // ── Breakpoints ──────────────────────────────────────────────────────────

  bool get isPhone => width < 600;
  bool get isTablet => width >= 600 && width <= 900;
  bool get isDesktop => width > 900;

  // ── Percentage-based sizing ──────────────────────────────────────────────

  /// Returns [percent]% of the screen **width**.
  double wp(double percent) => width * percent / 100;

  /// Returns [percent]% of the screen **height**.
  double hp(double percent) => height * percent / 100;

  // ── Scaled font size ────────────────────────────────────────────────────

  /// Scales a design-time font [size] proportionally to screen width,
  /// using 375 px as the baseline (iPhone SE / small phone).
  /// The result is clamped so text never shrinks below 70 % or grows
  /// beyond 130 % of the original.
  double sp(double size) {
    final scale = width / 375;
    return size * scale.clamp(0.7, 1.3);
  }

  // ── Adaptive padding ───────────────────────────────────────────────────

  /// Horizontal content padding that grows with screen width.
  double get horizontalPadding {
    if (isDesktop) return 80;
    if (isTablet) return 40;
    return max(16, wp(5));
  }

  // ── Adaptive grid ──────────────────────────────────────────────────────

  /// Number of grid columns for service selection grids.
  int get gridColumns {
    if (isDesktop) return 4;
    if (isTablet) return 3;
    return 2;
  }

  // ── Content max-width ──────────────────────────────────────────────────

  /// Maximum width for form-like content (login, signup, profile, etc.)
  /// so it doesn't stretch to fill ultra-wide viewports.
  double get formMaxWidth => 500;

  /// Maximum width for general page content.
  double get contentMaxWidth => 700;
}
