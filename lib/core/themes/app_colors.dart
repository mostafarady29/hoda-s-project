// lib/core/themes/app_colors.dart
// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

/// Academic Expert System Color System
/// Designed for trust, intelligence, and academic structure
/// Compliant with WCAG 2.1 AA accessibility standards
@immutable
class AppColors {
  const AppColors._();

  // ==================== BRAND COLORS ====================
  /// Primary Authority Blue - Deep trust, institutional feel
  static const Color primaryDeep = Color(0xFF1A5A9A);

  /// Main Interactive Color - Actionable elements
  static const Color primaryMain = Color(0xFF1B82A5);

  /// Soft Background Highlight - Selection, hover states
  static const Color primarySoft = Color(0xFFBAD1DB);

  /// Muted Surface Color - Cards, borders, subtle backgrounds
  static const Color primaryMuted = Color(0xFFBAD4DF);

  /// Modern Teal - Gradients and CTAs
  static const Color tealHighlight = Color(0xFF2EA4AE);

  // ==================== NEUTRAL SCALES ====================
  /// Light theme background scale
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF1F5F9);

  /// Dark theme background scale
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceVariantDark = Color(0xFF334155);

  /// Text colors - Light theme
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF64748B);
  static const Color textDisabledLight = Color(0xFF94A3B8);

  /// Text colors - Dark theme
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFFCBD5E1);
  static const Color textTertiaryDark = Color(0xFF94A3B8);
  static const Color textDisabledDark = Color(0xFF64748B);

  /// Border and divider colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);

  // ==================== SEMANTIC COLORS ====================
  /// Success - Academic achievement, completed tasks
  static const Color successMain = Color(0xFF059669);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF047857);
  static const Color successBg = Color(0xFFD1FAE5);
  static const Color successBgDark = Color(0xFF064E3B);

  /// Warning - Prerequisite alerts, academic probation
  static const Color warningMain = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFB45309);
  static const Color warningBg = Color(0xFFFEF3C7);
  static const Color warningBgDark = Color(0xFF78350F);

  /// Error - Failures, critical flags
  static const Color errorMain = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFB91C1C);
  static const Color errorBg = Color(0xFFFEE2E2);
  static const Color errorBgDark = Color(0xFF7F1D1D);

  /// Info - General information, help text
  static const Color infoMain = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFDBEAFE);
  static const Color infoBgDark = Color(0xFF1E3A8A);

  // ==================== ACCENT COLORS ====================
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentOrange = Color(0xFFF97316);
  static const Color accentRose = Color(0xFFF43F5E);
  static const Color accentIndigo = Color(0xFF6366F1);

  // ==================== ACADEMIC SPECIFIC ====================
  /// GPA indicator - Excellent performance
  static const Color gpaExcellent = Color(0xFF059669);

  /// GPA indicator - Good standing
  static const Color gpaGood = Color(0xFF3B82F6);

  /// GPA indicator - Satisfactory
  static const Color gpaSatisfactory = Color(0xFFF59E0B);

  /// GPA indicator - Warning zone
  static const Color gpaWarning = Color(0xFFF97316);

  /// GPA indicator - Academic probation
  static const Color gpaProbation = Color(0xFFEF4444);

  // ==================== GRADIENT PRESETS ====================
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, primaryMain, tealHighlight],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDeep, tealHighlight],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [successMain, successLight],
  );

  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [warningMain, warningLight],
  );

  static const LinearGradient errorGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [errorMain, errorLight],
  );

  static const LinearGradient softBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primarySoft, Color(0xFFFFFFFF)],
  );

  static const LinearGradient dashboardCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  // ==================== OPACITY OVERLAYS ====================
  static const Color overlayLight = Color(0x1A0F172A);
  static const Color overlayMedium = Color(0x330F172A);
  static const Color overlayDark = Color(0x660F172A);
  static const Color overlayBlackLight = Color(0x1A000000);
  static const Color overlayBlackMedium = Color(0x33000000);
  static const Color overlayBlackDark = Color(0x66000000);

  // ==================== STATE COLORS ====================
  static const Color hoverLight = Color(0x0A1A5A9A);
  static const Color pressedLight = Color(0x141A5A9A);
  static const Color disabledLight = Color(0x1A94A3B8);
  static const Color hoverDark = Color(0x0A3B82F6);
  static const Color pressedDark = Color(0x143B82F6);
  static const Color disabledDark = Color(0x1A64748B);

  // ==================== ACCESSIBILITY ====================
  /// High contrast mode overrides
  static const Color highContrastText = Color(0xFF000000);
  static const Color highContrastBg = Color(0xFFFFFFFF);
  static const Color highContrastBorder = Color(0xFF000000);
  static const Color highContrastFocusRing = Color(0xFF000000);
}
