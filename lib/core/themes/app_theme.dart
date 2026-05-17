// lib/core/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// Main Theme Engine - Complete Professional System
class AppTheme {
  const AppTheme._();

  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;

  // Spacing System
  static const double spacingUnit = 8.0;
  static const double spacingXXS = 2.0;
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;

  // Radius System
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusCircular = 100.0;

  static double getAdaptiveSpacing(BuildContext context, double baseSpacing) {
    final width = MediaQuery.of(context).size.width;
    if (width >= desktopBreakpoint) return baseSpacing * 1.25;
    if (width >= tabletBreakpoint) return baseSpacing * 1.125;
    return baseSpacing;
  }

  // ==================== LIGHT THEME ====================
  static ThemeData lightTheme(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= tabletBreakpoint;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryMain,
        secondary: AppColors.tealHighlight,
        tertiary: AppColors.accentPurple,
        error: AppColors.errorMain,
        surface: AppColors.surfaceLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryLight,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.backgroundLight,

      // Typography
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
        ),
        clipBehavior: Clip.antiAlias,
        color: AppColors.surfaceLight,
        surfaceTintColor: Colors.transparent,
      ),

      // AppBar Theme
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.textPrimaryLight,
        titleTextStyle: AppTextStyles.titleLarge,
        toolbarHeight: isDesktop ? 72 : 64,
        iconTheme:
            const IconThemeData(color: AppColors.textSecondaryLight, size: 24),
        actionsIconTheme:
            const IconThemeData(color: AppColors.textSecondaryLight, size: 24),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primaryMain,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.disabledLight,
          padding: EdgeInsets.symmetric(
            horizontal: spacingMD,
            vertical: isDesktop ? spacingMD : spacingSM,
          ),
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          side: const BorderSide(color: AppColors.borderLight, width: 1),
          padding: EdgeInsets.symmetric(
            horizontal: spacingMD,
            vertical: isDesktop ? spacingMD : spacingSM,
          ),
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryMain,
          padding: EdgeInsets.symmetric(
            horizontal: spacingSM,
            vertical: isDesktop ? spacingSM : spacingXS,
          ),
          textStyle: AppTextStyles.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.primaryMain, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.errorMain),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.errorMain, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: spacingMD,
          vertical: isDesktop ? spacingMD : spacingSM,
        ),
        labelStyle: AppTextStyles.bodyMedium,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textTertiaryLight,
        ),
        errorStyle: AppTextStyles.captionSmall.copyWith(
          color: AppColors.errorMain,
        ),
      ),

      // Data Table
      dataTableTheme: DataTableThemeData(
        columnSpacing: spacingLG,
        horizontalMargin: spacingMD,
        headingTextStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: AppTextStyles.bodyMedium,
        headingRowColor: WidgetStateProperty.resolveWith(
          (_) => AppColors.surfaceVariantLight,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return AppColors.primarySoft.withValues(alpha: 0.3);
          }
          if (states.contains(WidgetState.selected)) {
            return AppColors.primarySoft.withValues(alpha: 0.2);
          }
          return Colors.transparent;
        }),
        dividerThickness: 1,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXL),
        ),
        elevation: 0,
        backgroundColor: AppColors.surfaceLight,
        titleTextStyle: AppTextStyles.headlineSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
        actionsPadding: const EdgeInsets.all(spacingMD),
      ),

      // Navigation Rail
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        selectedIconTheme:
            const IconThemeData(color: AppColors.primaryMain, size: 24),
        unselectedIconTheme:
            const IconThemeData(color: AppColors.textTertiaryLight, size: 24),
        selectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.primaryMain,
        ),
        unselectedLabelTextStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textTertiaryLight,
        ),
        groupAlignment: -1,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primaryMain,
        unselectedItemColor: AppColors.textTertiaryLight,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
        space: spacingMD,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariantLight,
        deleteIconColor: AppColors.textTertiaryLight,
        labelStyle: AppTextStyles.labelMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingSM,
          vertical: spacingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSM),
        ),
      ),

      // Popup Menu
      popupMenuTheme: PopupMenuThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
        color: AppColors.surfaceLight,
        textStyle: AppTextStyles.bodyMedium,
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.overlayDark,
          borderRadius: BorderRadius.circular(radiusSM),
        ),
        textStyle: AppTextStyles.captionSmall.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  // ==================== DARK THEME ====================
  static ThemeData darkTheme(BuildContext context) {
    final baseLightTheme = lightTheme(context);

    return baseLightTheme.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryMain,
        secondary: AppColors.tealHighlight,
        tertiary: AppColors.accentPurple,
        error: AppColors.errorMain,
        surface: AppColors.surfaceDark,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimaryDark,
        onError: Colors.white,
      ),
      cardTheme: baseLightTheme.cardTheme.copyWith(
        color: AppColors.surfaceDark,
      ),
      appBarTheme: baseLightTheme.appBarTheme.copyWith(
        foregroundColor: AppColors.textPrimaryDark,
        iconTheme: const IconThemeData(color: AppColors.textSecondaryDark),
        actionsIconTheme:
            const IconThemeData(color: AppColors.textSecondaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: baseLightTheme.elevatedButtonTheme.style?.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled))
              return AppColors.disabledDark;
            return AppColors.primaryMain;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: baseLightTheme.outlinedButtonTheme.style?.copyWith(
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.borderDark),
          ),
        ),
      ),
      inputDecorationTheme: baseLightTheme.inputDecorationTheme.copyWith(
        fillColor: AppColors.surfaceDark,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: AppColors.primaryMain, width: 2),
        ),
      ),
      dataTableTheme: baseLightTheme.dataTableTheme.copyWith(
        headingRowColor: WidgetStateProperty.resolveWith(
          (_) => AppColors.surfaceVariantDark,
        ),
      ),
      dialogTheme: baseLightTheme.dialogTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
      ),
      bottomNavigationBarTheme:
          baseLightTheme.bottomNavigationBarTheme.copyWith(
        backgroundColor: AppColors.surfaceDark,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
      ),
      chipTheme: baseLightTheme.chipTheme.copyWith(
        backgroundColor: AppColors.surfaceVariantDark,
      ),
      popupMenuTheme: baseLightTheme.popupMenuTheme.copyWith(
        color: AppColors.surfaceDark,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLargeDark,
        displayMedium: AppTextStyles.displayMediumDark,
        displaySmall: AppTextStyles.displaySmallDark,
        headlineLarge: AppTextStyles.headlineLargeDark,
        headlineMedium: AppTextStyles.headlineMediumDark,
        headlineSmall: AppTextStyles.headlineSmallDark,
        titleLarge: AppTextStyles.titleLargeDark,
        titleMedium: AppTextStyles.titleMediumDark,
        titleSmall: AppTextStyles.titleSmallDark,
        bodyLarge: AppTextStyles.bodyLargeDark,
        bodyMedium: AppTextStyles.bodyMediumDark,
        bodySmall: AppTextStyles.bodySmallDark,
        labelLarge: AppTextStyles.labelLargeDark,
        labelMedium: AppTextStyles.labelMediumDark,
        labelSmall: AppTextStyles.labelSmallDark,
      ),
    );
  }

  // ==================== HIGH CONTRAST THEME ====================
  static ThemeData highContrastTheme(BuildContext context) {
    final baseTheme = lightTheme(context);

    return baseTheme.copyWith(
      colorScheme: const ColorScheme.highContrastLight(
        primary: AppColors.primaryDeep,
        secondary: AppColors.tealHighlight,
        error: AppColors.errorMain,
        surface: AppColors.highContrastBg,
        onPrimary: AppColors.highContrastText,
        onSecondary: AppColors.highContrastText,
        onSurface: AppColors.highContrastText,
        onError: AppColors.highContrastBg,
      ),
      scaffoldBackgroundColor: AppColors.highContrastBg,
      cardTheme: baseTheme.cardTheme.copyWith(
        color: AppColors.highContrastBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          side: const BorderSide(
            color: AppColors.highContrastBorder,
            width: 2,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: baseTheme.elevatedButtonTheme.style?.copyWith(
          side: WidgetStateProperty.all(
            const BorderSide(color: AppColors.highContrastBorder),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return Colors.grey;
            return AppColors.primaryDeep;
          }),
        ),
      ),
      inputDecorationTheme: baseTheme.inputDecorationTheme.copyWith(
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(
            color: AppColors.highContrastBorder,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(
            color: AppColors.highContrastBorder,
            width: 3,
          ),
        ),
      ),
      focusColor: AppColors.highContrastFocusRing,
    );
  }

  // ==================== MAIN GETTER ====================
  static ThemeData getTheme(BuildContext context,
      {bool isDark = false, bool highContrast = false}) {
    if (highContrast) return highContrastTheme(context);
    if (isDark) return darkTheme(context);
    return lightTheme(context);
  }

  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
