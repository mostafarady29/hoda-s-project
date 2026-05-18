// lib/features/data_import/presentation/screens/import_progress_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_shadows.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../data/models/student_index_model.dart';
import '../../../../core/themes/app_theme.dart';
import '../cubit/upload_cubit.dart';

class ImportProgressScreen extends StatelessWidget {
  final void Function(String jobId, StudentIndexModel index) onCompleted;
  final VoidCallback onCancelled;

  const ImportProgressScreen({
    super.key,
    required this.onCompleted,
    required this.onCancelled,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UploadCubit, UploadState>(
      listener: (context, state) {
        if (state is UploadCompleted) {
          onCompleted(state.jobId, state.index);
        }
      },
      builder: (context, state) {
        final isDark = AppTheme.isDarkMode(context);
        return Scaffold(
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          body: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: _ProgressBody(
                state: state,
                onCancelled: onCancelled,
                isDark: isDark,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressBody extends StatelessWidget {
  final UploadState state;
  final VoidCallback onCancelled;
  final bool isDark;

  const _ProgressBody({
    required this.state,
    required this.onCancelled,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _AnimatedStatusIcon(state: state),
            const SizedBox(height: AppTheme.spacingXL),
            _StatusTitle(state: state, isDark: isDark),
            const SizedBox(height: AppTheme.spacingSM),
            _StatusSubtitle(state: state, isDark: isDark),
            const SizedBox(height: AppTheme.spacingXXL),
            _StepsIndicator(state: state),
            const SizedBox(height: AppTheme.spacingXXL),
            if (state is UploadCompleted)
              _StatsCard(
                index: (state as UploadCompleted).index,
                isDark: isDark,
              ),
            if (state is UploadFailure)
              _ErrorCard(
                message: (state as UploadFailure).message,
                onRetry: onCancelled,
                isDark: isDark,
              ),
            if (state is UploadInProgress || state is UploadPolling) ...[
              const SizedBox(height: AppTheme.spacingLG),
              TextButton.icon(
                onPressed: () => _confirmCancel(context),
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: Text(
                  'إلغاء',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmCancel(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء المعالجة؟'),
        content: const Text('هل تريد إلغاء عملية الرفع والمعالجة الحالية؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('استمرار')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.errorMain),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
    if (confirm == true) onCancelled();
  }
}

// ─────────────────────────────────────────────
// Animated icon
// ─────────────────────────────────────────────
class _AnimatedStatusIcon extends StatefulWidget {
  final UploadState state;
  const _AnimatedStatusIcon({required this.state});

  @override
  State<_AnimatedStatusIcon> createState() => _AnimatedStatusIconState();
}

class _AnimatedStatusIconState extends State<_AnimatedStatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulse = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.state is UploadCompleted;
    final isFailed = widget.state is UploadFailure;

    if (isDone) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.successBg,
          shape: BoxShape.circle,
          boxShadow: AppShadows.academicCard,
        ),
        child: const Icon(Icons.check_rounded,
            color: AppColors.successMain, size: 52),
      );
    }

    if (isFailed) {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.errorBg,
          shape: BoxShape.circle,
          boxShadow: AppShadows.soft,
        ),
        child: const Icon(Icons.error_outline_rounded,
            color: AppColors.errorMain, size: 52),
      );
    }

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, __) => Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryMain
                  .withValues(alpha: 0.2 + _pulse.value * 0.15),
              AppColors.tealHighlight
                  .withValues(alpha: 0.1 + _pulse.value * 0.1),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMain
                  .withValues(alpha: 0.2 + _pulse.value * 0.15),
              blurRadius: 20 + _pulse.value * 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primaryMain,
            backgroundColor: AppColors.primarySoft.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Title
// ─────────────────────────────────────────────
class _StatusTitle extends StatelessWidget {
  final UploadState state;
  final bool isDark;
  const _StatusTitle({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    String title;
    Color color =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    if (state is UploadInProgress) {
      title = 'جاري رفع الملف...';
    } else if (state is UploadPolling) {
      final s = state as UploadPolling;
      title = s.status.statusLabel;
    } else if (state is UploadCompleted) {
      final s = state as UploadCompleted;
      title = s.index.status == 'partial_success'
          ? 'اكتملت مع تحذيرات'
          : 'اكتملت بنجاح ✓';
      color = AppColors.successMain;
    } else if (state is UploadFailure) {
      title = 'فشلت المعالجة';
      color = AppColors.errorMain;
    } else {
      title = 'في الانتظار...';
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Text(
        title,
        key: ValueKey(title),
        style: AppTextStyles.headlineSmall
            .copyWith(color: color, fontWeight: FontWeight.w700),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Subtitle / job ID
// ─────────────────────────────────────────────
class _StatusSubtitle extends StatelessWidget {
  final UploadState state;
  final bool isDark;
  const _StatusSubtitle({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    String? jobId;
    String? subtitle;

    if (state is UploadPolling) {
      jobId = (state as UploadPolling).jobId;
      subtitle = 'جاري قراءة وتحليل بيانات الطلاب...';
    } else if (state is UploadCompleted) {
      jobId = (state as UploadCompleted).jobId;
    }

    if (jobId == null && subtitle == null) return const SizedBox.shrink();

    return Column(
      children: [
        if (subtitle != null)
          Text(
            subtitle,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        if (jobId != null) ...[
          const SizedBox(height: AppTheme.spacingXS),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSM, vertical: AppTheme.spacingXS),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSM),
            ),
            child: Text(
              'Job: ${jobId.substring(0, 8)}...',
              style: AppTextStyles.captionMedium.copyWith(
                fontFamily: 'monospace',
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Steps indicator
// ─────────────────────────────────────────────
class _StepsIndicator extends StatelessWidget {
  final UploadState state;
  const _StepsIndicator({required this.state});

  int get _currentStep {
    if (state is UploadInProgress) return 0;
    if (state is UploadPolling) return 1;
    if (state is UploadCompleted || state is UploadFailure) return 2;
    return 0;
  }

  bool get _isFailed => state is UploadFailure;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.cloud_upload_rounded, 'رفع الملف'),
      (Icons.memory_rounded, 'معالجة'),
      (Icons.task_alt_rounded, 'اكتمل'),
    ];
    final current = _currentStep;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final stepIndex = i ~/ 2;
          final isPast = current > stepIndex;
          return Container(
            width: 48,
            height: 2,
            margin: const EdgeInsets.only(bottom: 28),
            decoration: BoxDecoration(
              gradient: isPast ? AppColors.heroGradient : null,
              color: isPast ? null : AppColors.borderLight,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final isPast = current > stepIndex;
        final isCurrent = current == stepIndex;
        final isFailedStep = _isFailed && stepIndex == 2;

        Color bgColor;
        Color iconColor;
        if (isFailedStep) {
          bgColor = AppColors.errorBg;
          iconColor = AppColors.errorMain;
        } else if (isPast || isCurrent) {
          bgColor = AppColors.primaryMain;
          iconColor = Colors.white;
        } else {
          bgColor = AppColors.surfaceVariantLight;
          iconColor = AppColors.textTertiaryLight;
        }

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                boxShadow: isCurrent && !_isFailed ? AppShadows.kpiCard : [],
              ),
              child: Icon(steps[stepIndex].$1, color: iconColor, size: 20),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              steps[stepIndex].$2,
              style: AppTextStyles.labelSmall.copyWith(
                color: isPast || isCurrent
                    ? AppColors.primaryMain
                    : AppColors.textTertiaryLight,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────
// Stats card (on success)
// ─────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final StudentIndexModel index;
  final bool isDark;
  const _StatsCard({required this.index, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        gradient: AppColors.glassGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: AppColors.successMain.withValues(alpha: 0.2)),
        boxShadow: AppShadows.academicCard,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
              value: '${index.totalStudents}',
              label: 'إجمالي الطلاب',
              color: AppColors.primaryMain),
          const _Divider(),
          _StatItem(
              value: '${index.students.length}',
              label: 'تمت قراءتهم',
              color: AppColors.successMain),
          if (index.errors.isNotEmpty) ...[
            const _Divider(),
            _StatItem(
                value: '${index.errors.length}',
                label: 'تحذيرات',
                color: AppColors.warningMain),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatItem(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTextStyles.headlineMedium
                .copyWith(color: color, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.captionMedium),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: AppColors.borderLight);
  }
}

// ─────────────────────────────────────────────
// Error card
// ─────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;
  const _ErrorCard(
      {required this.message, required this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMD),
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(color: AppColors.errorMain.withValues(alpha: 0.3)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          Text(message,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.errorDark),
              textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.spacingMD),
          OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.errorMain,
              side: const BorderSide(color: AppColors.errorMain),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMD)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('حاول مجدداً'),
          ),
        ],
      ),
    );
  }
}
