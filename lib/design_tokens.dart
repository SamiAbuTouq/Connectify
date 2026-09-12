import 'package:flutter/material.dart';

/// CONNECTIFY Monochrome Design System Tokens
/// Inspired by Apple, Linear, and Notion minimalist monochrome aesthetics.

class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // Greyscale Scale (11-step ladder)
  // ---------------------------------------------------------------------------
  static const Color grey50 = Color(0xFFFAFAFA); // Subtle canvas / hover tint
  static const Color grey100 = Color(0xFFF4F4F5); // Muted container / card fill
  static const Color grey200 = Color(0xFFE4E4E7); // Subtle borders & dividers
  static const Color grey300 = Color(0xFFD4D4D8); // Strong borders / inactive elements
  static const Color grey400 = Color(0xFFA1A1AA); // Muted placeholder / disabled text
  static const Color grey500 = Color(0xFF71717A); // Secondary text / icons
  static const Color grey600 = Color(0xFF52525B); // Medium contrast body / sub-headlines
  static const Color grey700 = Color(0xFF3F3F46); // High contrast dark grey
  static const Color grey800 = Color(0xFF27272A); // Dark mode card surface / borders
  static const Color grey900 = Color(0xFF18181B); // Dark mode surface / primary light
  static const Color grey950 = Color(0xFF09090B); // Deepest dark canvas

  // ---------------------------------------------------------------------------
  // Absolute Extremes & Near-Extremes
  // ---------------------------------------------------------------------------
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);
  static const Color nearBlack = Color(0xFF111111); // Premium softened dark tone
  static const Color nearWhite = Color(0xFFF8F8F8);

  // ---------------------------------------------------------------------------
  // Semantic Light Mode Tokens
  // ---------------------------------------------------------------------------
  static const Color lightBg = Color(0xFFFFFFFF);
  static const Color lightBgSubtle = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF4F4F5);
  static const Color lightBorder = Color(0xFFE4E4E7);
  static const Color lightBorderSubtle = Color(0xFFF0F0F2);
  static const Color lightBorderStrong = Color(0xFFD4D4D8);
  static const Color lightTextPrimary = Color(0xFF111111);
  static const Color lightTextSecondary = Color(0xFF71717A);
  static const Color lightTextMuted = Color(0xFFA1A1AA);
  static const Color lightTextDisabled = Color(0xFFD4D4D8);

  // ---------------------------------------------------------------------------
  // Semantic Dark Mode Tokens
  // ---------------------------------------------------------------------------
  static const Color darkBg = Color(0xFF0A0A0A);
  static const Color darkBgSubtle = Color(0xFF111111);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceElevated = Color(0xFF1A1A1A);
  static const Color darkSurfaceMuted = Color(0xFF222225);
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkBorderSubtle = Color(0xFF1F1F22);
  static const Color darkBorderStrong = Color(0xFF3F3F46);
  static const Color darkTextPrimary = Color(0xFFF4F4F5);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);
  static const Color darkTextMuted = Color(0xFF71717A);
  static const Color darkTextDisabled = Color(0xFF52525B);
}

/// Standardized Spacing Tokens
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // Reusable EdgeInsets helpers
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);

  static const EdgeInsets horizontalXs = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSm = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXl = EdgeInsets.symmetric(horizontal: xl);

  static const EdgeInsets verticalXs = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXl = EdgeInsets.symmetric(vertical: xl);

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: lg,
  );
}

/// Standardized Corner Radius Tokens
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 999.0;

  // Reusable BorderRadius helpers
  static final BorderRadius radiusXsBorder = BorderRadius.circular(xs);
  static final BorderRadius radiusSmBorder = BorderRadius.circular(sm);
  static final BorderRadius radiusMdBorder = BorderRadius.circular(md);
  static final BorderRadius radiusLgBorder = BorderRadius.circular(lg);
  static final BorderRadius radiusXlBorder = BorderRadius.circular(xl);
  static final BorderRadius radiusXxlBorder = BorderRadius.circular(xxl);
  static final BorderRadius radiusFullBorder = BorderRadius.circular(full);
}

/// Refined Minimalist Shadows (Linear / Apple style depth)
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 10,
      offset: Offset(0, 3),
    ),
    BoxShadow(
      color: Color(0x04000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
    BoxShadow(
      color: Color(0x06000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> darkSubtle = [
    BoxShadow(
      color: Color(0x40000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> darkMedium = [
    BoxShadow(
      color: Color(0x73000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

/// Standardized Typography Scale
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Poppins';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    height: 1.25,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.4,
    height: 1.3,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.35,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.25,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.3,
  );
}

/// CONNECTIFY Asset Path Constants
class AppAssets {
  AppAssets._();

  static const String defaultAvatar = 'assets/images/default_avatar.png';
}

