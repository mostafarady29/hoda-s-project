// lib/core/themes/app_shadows.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shadow System for Academic Expert System
/// Modern SaaS-style layered elevations
/// No harsh Material defaults - subtle and sophisticated
@immutable
class AppShadows {
  const AppShadows._();

  // ==================== ELEVATION SYSTEM ====================
  /// Extra soft shadow - Subtle depth for cards on white backgrounds
  static List<BoxShadow> get soft => [
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 8,
          offset: const Offset(0, 1),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 4,
          offset: const Offset(0, 1),
          spreadRadius: -2,
        ),
      ];

  /// Card shadow - Default for cards, surfaces
  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];

  /// Medium shadow - Modals, dropdowns, floating elements
  static List<BoxShadow> get medium => [
        BoxShadow(
          color: AppColors.overlayMedium,
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 8,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  /// Strong shadow - Dialogs, important modals
  static List<BoxShadow> get strong => [
        BoxShadow(
          color: AppColors.overlayDark,
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.overlayMedium,
          blurRadius: 12,
          offset: const Offset(0, 16),
          spreadRadius: -6,
        ),
      ];

  /// Floating UI shadow - FAB, floating panels, tooltips
  static List<BoxShadow> get floating => [
        BoxShadow(
          color: AppColors.overlayDark,
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 10,
          offset: const Offset(0, 12),
          spreadRadius: -4,
        ),
      ];

  /// Hover state shadow - Interactive elements on hover
  static List<BoxShadow> get hover => [
        BoxShadow(
          color: AppColors.overlayMedium,
          blurRadius: 12,
          offset: const Offset(0, 3),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 6,
          offset: const Offset(0, 6),
          spreadRadius: -3,
        ),
      ];

  /// Pressed state shadow - Elements being pressed
  static List<BoxShadow> get pressed => [
        BoxShadow(
          color: AppColors.overlayMedium,
          blurRadius: 8,
          offset: const Offset(0, 1),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 4,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];

  /// Academic card shadow - Slightly deeper for importance
  static List<BoxShadow> get academicCard => [
        BoxShadow(
          // ignore: deprecated_member_use
          color: AppColors.primarySoft.withOpacity(0.15),
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: -1,
        ),
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
      ];

  /// KPI card shadow - Dashboard metrics, premium feel
  static List<BoxShadow> get kpiCard => [
        BoxShadow(
          // ignore: deprecated_member_use
          color: AppColors.tealHighlight.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 10,
          offset: const Offset(0, 4),
          spreadRadius: -3,
        ),
      ];

  /// Data table row shadow - Subtle separation
  static List<BoxShadow> get tableRow => [
        BoxShadow(
          color: AppColors.overlayLight,
          blurRadius: 4,
          offset: const Offset(0, 1),
          spreadRadius: -1,
        ),
      ];

  /// Hover table row - Interactive rows
  static List<BoxShadow> get tableRowHover => [
        BoxShadow(
          // ignore: deprecated_member_use
          color: AppColors.primarySoft.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: -1,
        ),
      ];

  /// No shadow - Flat design elements
  static const List<BoxShadow> none = [];

  // ==================== DARK MODE VARIANTS ====================
  static List<BoxShadow> get cardDark => [
        BoxShadow(
          color: AppColors.overlayBlackMedium,
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.overlayBlackLight,
          blurRadius: 6,
          offset: const Offset(0, 4),
          spreadRadius: -4,
        ),
      ];

  static List<BoxShadow> get mediumDark => [
        BoxShadow(
          color: AppColors.overlayBlackDark,
          blurRadius: 16,
          offset: const Offset(0, 4),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: AppColors.overlayBlackMedium,
          blurRadius: 8,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ];

  // ==================== ACCESSIBILITY ====================
  /// High contrast focus ring shadow (accessibility)
  static List<BoxShadow> get focusRing => [
        BoxShadow(
          // ignore: deprecated_member_use
          color: AppColors.primaryMain.withOpacity(0.4),
          blurRadius: 0,
          offset: Offset.zero,
          spreadRadius: 2,
        ),
      ];
}
