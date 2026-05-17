// lib/core/themes/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography System for Academic Expert System
@immutable
class AppTextStyles {
  const AppTextStyles._();

  static double getFontScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1.0);
  }

  // Display Styles
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        height: 1.12,
        letterSpacing: -0.5,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get displayMedium => GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w600,
        height: 1.15,
        letterSpacing: -0.3,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get displaySmall => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.2,
        color: AppColors.textPrimaryLight,
      );

  // Headline Styles
  static TextStyle get headlineLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.2,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: -0.1,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0,
        color: AppColors.textPrimaryLight,
      );

  // Title Styles
  static TextStyle get titleLarge => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
        letterSpacing: 0,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.1,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
        color: AppColors.textSecondaryLight,
      );

  // Body Styles
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.15,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.25,
        color: AppColors.textSecondaryLight,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.5,
        letterSpacing: 0.4,
        color: AppColors.textTertiaryLight,
      );

  // Label Styles
  static TextStyle get labelLarge => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        letterSpacing: 0.1,
        color: AppColors.textPrimaryLight,
      );

  static TextStyle get labelMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        letterSpacing: 0.5,
        color: AppColors.textSecondaryLight,
      );

  static TextStyle get labelSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: 0.5,
        color: AppColors.textTertiaryLight,
      );

  // Caption Styles
  static TextStyle get captionLarge => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.38,
        letterSpacing: 0.4,
        color: AppColors.textTertiaryLight,
      );

  static TextStyle get captionMedium => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        letterSpacing: 0.4,
        color: AppColors.textTertiaryLight,
      );

  static TextStyle get captionSmall => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.45,
        letterSpacing: 0.4,
        color: AppColors.textTertiaryLight,
      );

  // Academic Specific
  static TextStyle get gpaDisplay => GoogleFonts.inter(
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.5,
        color: AppColors.primaryDeep,
      );

  static TextStyle get courseCode => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.4,
        letterSpacing: 0.2,
        color: AppColors.primaryMain,
      );

  static TextStyle get prerequisiteWarning => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.2,
        color: AppColors.warningMain,
      );

  static TextStyle get statusBadge => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.5,
        color: Colors.white,
      );

  // Dark Mode Variants
  static TextStyle get displayLargeDark =>
      displayLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get displayMediumDark =>
      displayMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get displaySmallDark =>
      displaySmall.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get headlineLargeDark =>
      headlineLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get headlineMediumDark =>
      headlineMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get headlineSmallDark =>
      headlineSmall.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get titleLargeDark =>
      titleLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get titleMediumDark =>
      titleMedium.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get titleSmallDark =>
      titleSmall.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle get bodyLargeDark =>
      bodyLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get bodyMediumDark =>
      bodyMedium.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle get bodySmallDark =>
      bodySmall.copyWith(color: AppColors.textTertiaryDark);
  static TextStyle get labelLargeDark =>
      labelLarge.copyWith(color: AppColors.textPrimaryDark);
  static TextStyle get labelMediumDark =>
      labelMedium.copyWith(color: AppColors.textSecondaryDark);
  static TextStyle get labelSmallDark =>
      labelSmall.copyWith(color: AppColors.textTertiaryDark);

  static TextStyle scaleForAccessibility(
      BuildContext context, TextStyle style) {
    final scale = getFontScale(context);
    return style.copyWith(fontSize: style.fontSize! * scale);
  }

  static TextStyle get highContrastBody => bodyLarge.copyWith(
        color: AppColors.highContrastText,
        fontWeight: FontWeight.w600,
      );
}
