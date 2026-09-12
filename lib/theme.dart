import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';

export 'design_tokens.dart';

/// CONNECTIFY Design System Theme
/// A high-end, strictly monochrome (black & white / greyscale) design system
/// inspired by Apple, Linear, and Notion minimalist interfaces.
class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Backwards-Compatible Tokens & Aliases
  // ---------------------------------------------------------------------------
  static const String fontFamily = AppTypography.fontFamily;

  // Primary & Secondary Brand Colors (Strictly Monochrome)
  static const Color primaryColor = AppColors.nearBlack;
  static const Color primaryDark = AppColors.pureBlack;
  static const Color primaryLight = AppColors.grey200;
  static const Color primaryContainer = AppColors.grey100;

  static const Color secondaryColor = AppColors.grey600;
  static const Color secondaryLight = AppColors.grey100;

  // Functional Greyscale Accents (replaces colored accents for strict monochrome)
  static const Color accentTeal = AppColors.grey700;
  static const Color accentGreen = AppColors.grey800;
  static const Color accentRed = AppColors.grey900;

  // Neutral Colors (Light)
  static const Color lightBackground = AppColors.lightBg;
  static const Color lightSurface = AppColors.lightSurface;
  static const Color lightSurfaceVariant = AppColors.lightSurfaceMuted;
  static const Color lightBorder = AppColors.lightBorder;
  static const Color lightTextPrimary = AppColors.lightTextPrimary;
  static const Color lightTextSecondary = AppColors.lightTextSecondary;
  static const Color lightTextMuted = AppColors.lightTextMuted;

  // Neutral Colors (Dark)
  static const Color darkBackground = AppColors.darkBg;
  static const Color darkSurface = AppColors.darkSurface;
  static const Color darkSurfaceVariant = AppColors.darkSurfaceMuted;
  static const Color darkBorder = AppColors.darkBorder;
  static const Color darkTextPrimary = AppColors.darkTextPrimary;
  static const Color darkTextSecondary = AppColors.darkTextSecondary;
  static const Color darkTextMuted = AppColors.darkTextMuted;

  // Standard Spacing Constants
  static const double spacingXxs = AppSpacing.xxs;
  static const double spacingXs = AppSpacing.xs;
  static const double spacingSm = AppSpacing.sm;
  static const double spacingMd = AppSpacing.md;
  static const double spacingLg = AppSpacing.lg;
  static const double spacingXl = AppSpacing.xl;
  static const double spacingXxl = AppSpacing.xxl;

  // Standard Radius Constants
  static const double radiusXs = AppRadius.xs;
  static const double radiusSm = AppRadius.sm;
  static const double radiusMd = AppRadius.md;
  static const double radiusLg = AppRadius.lg;
  static const double radiusXl = AppRadius.xl;
  static const double radiusXxl = AppRadius.xxl;
  static const double radiusFull = AppRadius.full;

  // ---------------------------------------------------------------------------
  // Text Themes
  // ---------------------------------------------------------------------------
  static final TextTheme _lightTextTheme = TextTheme(
    displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.lightTextPrimary),
    displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.lightTextPrimary),
    displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.lightTextPrimary),
    headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.lightTextPrimary),
    headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.lightTextPrimary),
    headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.lightTextPrimary),
    titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.lightTextPrimary),
    titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.lightTextPrimary),
    titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.lightTextSecondary),
    bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.lightTextPrimary),
    bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.lightTextSecondary),
    bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.lightTextMuted),
    labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.lightTextPrimary),
    labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.lightTextSecondary),
    labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.lightTextMuted),
  );

  static final TextTheme _darkTextTheme = TextTheme(
    displayLarge: AppTypography.displayLarge.copyWith(color: AppColors.darkTextPrimary),
    displayMedium: AppTypography.displayMedium.copyWith(color: AppColors.darkTextPrimary),
    displaySmall: AppTypography.displaySmall.copyWith(color: AppColors.darkTextPrimary),
    headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColors.darkTextPrimary),
    headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColors.darkTextPrimary),
    headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColors.darkTextPrimary),
    titleLarge: AppTypography.titleLarge.copyWith(color: AppColors.darkTextPrimary),
    titleMedium: AppTypography.titleMedium.copyWith(color: AppColors.darkTextPrimary),
    titleSmall: AppTypography.titleSmall.copyWith(color: AppColors.darkTextSecondary),
    bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.darkTextPrimary),
    bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColors.darkTextSecondary),
    bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.darkTextMuted),
    labelLarge: AppTypography.labelLarge.copyWith(color: AppColors.darkTextPrimary),
    labelMedium: AppTypography.labelMedium.copyWith(color: AppColors.darkTextSecondary),
    labelSmall: AppTypography.labelSmall.copyWith(color: AppColors.darkTextMuted),
  );

  // ---------------------------------------------------------------------------
  // LIGHT THEME
  // ---------------------------------------------------------------------------
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: AppColors.lightBg,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.nearBlack,
      onPrimary: AppColors.pureWhite,
      primaryContainer: AppColors.grey100,
      onPrimaryContainer: AppColors.nearBlack,
      secondary: AppColors.grey700,
      onSecondary: AppColors.pureWhite,
      secondaryContainer: AppColors.grey100,
      onSecondaryContainer: AppColors.grey900,
      tertiary: AppColors.grey600,
      onTertiary: AppColors.pureWhite,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      surfaceContainerLowest: AppColors.pureWhite,
      surfaceContainerLow: AppColors.lightBgSubtle,
      surfaceContainer: AppColors.grey50,
      surfaceContainerHigh: AppColors.grey100,
      surfaceContainerHighest: AppColors.grey200,
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorderSubtle,
      error: AppColors.nearBlack,
      onError: AppColors.pureWhite,
      shadow: Color(0x0F000000),
    ),

    // Typography
    textTheme: _lightTextTheme,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.lightBg,
      foregroundColor: AppColors.lightTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.lightTextPrimary,
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightTextPrimary,
        size: 22,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.lightTextPrimary,
        size: 22,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.pureWhite,
        backgroundColor: AppColors.nearBlack,
        iconColor: AppColors.pureWhite,
        disabledForegroundColor: AppColors.grey400,
        disabledBackgroundColor: AppColors.grey200,
        disabledIconColor: AppColors.grey400,
        iconSize: 20,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.nearBlack,
        iconColor: AppColors.nearBlack,
        disabledForegroundColor: AppColors.grey400,
        disabledIconColor: AppColors.grey400,
        iconSize: 20,
        side: const BorderSide(color: AppColors.lightBorder, width: 1.2),
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.nearBlack,
        iconColor: AppColors.nearBlack,
        disabledForegroundColor: AppColors.grey400,
        disabledIconColor: AppColors.grey400,
        iconSize: 20,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.grey50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.nearBlack, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.grey800, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.nearBlack, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.lightBorderSubtle, width: 1),
      ),
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.lightTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.lightTextMuted,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: AppColors.lightTextSecondary,
      suffixIconColor: AppColors.lightTextSecondary,
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.lightSurface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.grey100,
      disabledColor: AppColors.grey50,
      selectedColor: AppColors.nearBlack,
      secondarySelectedColor: AppColors.nearBlack,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.lightTextPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.pureWhite,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: AppColors.lightBorder, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      showCheckmark: false,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      selectedItemColor: AppColors.nearBlack,
      unselectedItemColor: AppColors.lightTextMuted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Navigation Bar Theme (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      indicatorColor: AppColors.grey100,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.nearBlack,
          );
        }
        return const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.lightTextMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.nearBlack, size: 24);
        }
        return const IconThemeData(color: AppColors.lightTextMuted, size: 24);
      }),
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.lightSurface,
      elevation: 8,
      shadowColor: const Color(0x1A000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.lightTextPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.lightTextSecondary,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.lightSurface,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.grey300,
    ),

    // Drawer Theme
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppRadius.lg)),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),

    // TabBar Theme
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.nearBlack,
      unselectedLabelColor: AppColors.lightTextMuted,
      indicatorColor: AppColors.nearBlack,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.nearBlack;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(AppColors.pureWhite),
      side: const BorderSide(color: AppColors.lightBorderStrong, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.pureWhite;
        }
        return AppColors.grey400;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.nearBlack;
        }
        return AppColors.grey200;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.nearBlack,
      foregroundColor: AppColors.pureWhite,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),

    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.nearBlack,
      contentTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.pureWhite,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.nearBlack,
      linearTrackColor: AppColors.grey200,
      circularTrackColor: AppColors.grey200,
    ),
  );

  // ---------------------------------------------------------------------------
  // DARK THEME
  // ---------------------------------------------------------------------------
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: AppColors.darkBg,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.pureWhite,
      onPrimary: AppColors.darkBg,
      primaryContainer: AppColors.grey800,
      onPrimaryContainer: AppColors.pureWhite,
      secondary: AppColors.grey400,
      onSecondary: AppColors.darkBg,
      secondaryContainer: AppColors.grey800,
      onSecondaryContainer: AppColors.grey200,
      tertiary: AppColors.grey500,
      onTertiary: AppColors.darkBg,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      surfaceContainerLowest: AppColors.darkBg,
      surfaceContainerLow: AppColors.darkBgSubtle,
      surfaceContainer: AppColors.darkSurface,
      surfaceContainerHigh: AppColors.darkSurfaceElevated,
      surfaceContainerHighest: AppColors.darkSurfaceMuted,
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorderSubtle,
      error: AppColors.pureWhite,
      onError: AppColors.darkBg,
      shadow: Color(0x66000000),
    ),

    // Typography
    textTheme: _darkTextTheme,

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkBg,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.darkTextPrimary,
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 22,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.darkTextPrimary,
        size: 22,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: AppColors.nearBlack,
        backgroundColor: AppColors.pureWhite,
        iconColor: AppColors.nearBlack,
        disabledForegroundColor: AppColors.grey600,
        disabledBackgroundColor: AppColors.grey800,
        disabledIconColor: AppColors.grey600,
        iconSize: 20,
        elevation: 0,
        shadowColor: Colors.transparent,
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.pureWhite,
        iconColor: AppColors.pureWhite,
        disabledForegroundColor: AppColors.grey600,
        disabledIconColor: AppColors.grey600,
        iconSize: 20,
        side: const BorderSide(color: AppColors.darkBorder, width: 1.2),
        minimumSize: const Size.fromHeight(50),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.pureWhite,
        iconColor: AppColors.pureWhite,
        disabledForegroundColor: AppColors.grey600,
        disabledIconColor: AppColors.grey600,
        iconSize: 20,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.pureWhite, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.grey400, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.pureWhite, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: const BorderSide(color: AppColors.darkBorderSubtle, width: 1),
      ),
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.darkTextSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      hintStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.darkTextMuted,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      prefixIconColor: AppColors.darkTextSecondary,
      suffixIconColor: AppColors.darkTextSecondary,
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.darkSurface,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.darkSurface,
      disabledColor: AppColors.darkBg,
      selectedColor: AppColors.pureWhite,
      secondarySelectedColor: AppColors.pureWhite,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      labelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.darkTextPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.darkBg,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      side: const BorderSide(color: AppColors.darkBorder, width: 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      showCheckmark: false,
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      selectedItemColor: AppColors.pureWhite,
      unselectedItemColor: AppColors.darkTextMuted,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Navigation Bar Theme (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      indicatorColor: AppColors.grey800,
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
          );
        }
        return const TextStyle(
          fontFamily: AppTypography.fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextMuted,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.pureWhite, size: 24);
        }
        return const IconThemeData(color: AppColors.darkTextMuted, size: 24);
      }),
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 12,
      shadowColor: const Color(0x66000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: AppColors.grey700,
    ),

    // Drawer Theme
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(AppRadius.lg)),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),

    // TabBar Theme
    tabBarTheme: const TabBarTheme(
      labelColor: AppColors.pureWhite,
      unselectedLabelColor: AppColors.darkTextMuted,
      indicatorColor: AppColors.pureWhite,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: AppTypography.fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.pureWhite;
        }
        return Colors.transparent;
      }),
      checkColor: const WidgetStatePropertyAll(AppColors.darkBg),
      side: const BorderSide(color: AppColors.darkBorderStrong, width: 1.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.darkBg;
        }
        return AppColors.grey500;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.pureWhite;
        }
        return AppColors.grey800;
      }),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.pureWhite,
      foregroundColor: AppColors.darkBg,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
    ),

    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.darkSurfaceElevated,
      contentTextStyle: const TextStyle(
        fontFamily: AppTypography.fontFamily,
        color: AppColors.pureWhite,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.pureWhite,
      linearTrackColor: AppColors.grey800,
      circularTrackColor: AppColors.grey800,
    ),
  );
}
