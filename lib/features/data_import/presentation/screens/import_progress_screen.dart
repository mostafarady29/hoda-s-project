// ===== File: lib/features/data_import/presentation/screens/import_progress_screen.dart =====

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../../data/models/import_status_model.dart';

enum ProgressStep { uploading, processing, done, failed }

class ImportProgressScreen extends StatefulWidget {
  /// Stream بيبعث [ImportStatusModel] أو null (uploading phase).
  /// لما يبعت status.isDone نروح لشاشة النتيجة.
  final Stream<ImportStatusModel?> statusStream;

  /// job_id للعرض
  final String? jobId;

  /// يُستدعى لما تكتمل المعالجة
  final void Function(String jobId) onCompleted;

  /// يُستدعى لما تفشل
  final void Function(String error) onFailed;

  /// يُستدعى لو الجيوزر ألغى
  final VoidCallback onCancelled;

  const ImportProgressScreen({
    super.key,
    required this.statusStream,
    this.jobId,
    required this.onCompleted,
    required this.onFailed,
    required this.onCancelled,
  });

  @override
  State<ImportProgressScreen> createState() => _ImportProgressScreenState();
}

class _ImportProgressScreenState extends State<ImportProgressScreen>
    with SingleTickerProviderStateMixin {
  ProgressStep _step = ProgressStep.uploading;
  ImportStatusModel? _latestStatus;
  String _message = 'جاري رفع الملف...';
  String? _errorMessage;

  late StreamSubscription<ImportStatusModel?> _sub;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _sub = widget.statusStream.listen(
      _onStatus,
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _step = ProgressStep.failed;
          _errorMessage = e.toString();
          _message = 'حدث خطأ غير متوقع';
        });
        widget.onFailed(e.toString());
      },
    );
  }

  void _onStatus(ImportStatusModel? status) {
    if (!mounted) return;

    if (status == null) {
      setState(() {
        _step = ProgressStep.uploading;
        _message = 'جاري رفع الملف...';
      });
      return;
    }

    setState(() => _latestStatus = status);

    if (status.isDone) {
      setState(() {
        _step = ProgressStep.done;
        _message = status.isPartialSuccess
            ? 'اكتملت المعالجة مع بعض التحذيرات'
            : 'اكتملت المعالجة بنجاح ✓';
      });
      _pulseController.stop();
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) widget.onCompleted(status.jobId);
      });
      return;
    }

    if (status.isFailed) {
      setState(() {
        _step = ProgressStep.failed;
        _errorMessage = status.errorLog.isNotEmpty
            ? status.errorLog.join('\n')
            : 'فشلت المعالجة';
        _message = 'فشلت المعالجة';
      });
      _pulseController.stop();
      widget.onFailed(_errorMessage!);
      return;
    }

    setState(() {
      _step = ProgressStep.processing;
      _message = _labelFor(status.status);
    });
  }

  String _labelFor(String status) {
    switch (status) {
      case 'pending':
        return 'في انتظار المعالجة...';
      case 'processing':
        return 'جاري قراءة وتحليل بيانات الطلاب...';
      default:
        return 'جاري المعالجة...';
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('معالجة الملف'),
        centerTitle: true,
        backgroundColor: colors.surface,
        elevation: 0,
        leading: _step == ProgressStep.failed
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: widget.onCancelled,
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Animated icon
                _StepIcon(step: _step, pulse: _pulseController),
                const SizedBox(height: 32),

                // ── Message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    _message,
                    key: ValueKey(_message),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _step == ProgressStep.failed
                              ? colors.error
                              : colors.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 12),

                // ── job ID
                if (widget.jobId != null || _latestStatus != null)
                  Text(
                    'Job ID: ${_latestStatus?.jobId ?? widget.jobId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 32),

                // ── Progress steps
                _StepsIndicator(current: _step),
                const SizedBox(height: 36),

                // ── Stats (if processing/done)
                if (_latestStatus?.stats.totalStudents != null &&
                    _latestStatus!.stats.totalStudents > 0)
                  _StatsRow(stats: _latestStatus!.stats),

                // ── Error details
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _ErrorDetails(
                      error: _errorMessage!, onRetry: widget.onCancelled),
                ],

                // ── Cancel button (only while active)
                if (_step == ProgressStep.uploading ||
                    _step == ProgressStep.processing) ...[
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => _showCancelDialog(context),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('إلغاء'),
                    style: TextButton.styleFrom(foregroundColor: colors.error),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إلغاء المعالجة؟'),
        content: const Text(
            'هل تريد إلغاء عملية الرفع والمعالجة؟ لن يُحفظ أي تقدم.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('استمرار')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('إلغاء')),
        ],
      ),
    );
    if (confirm == true && mounted) widget.onCancelled();
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _StepIcon extends StatelessWidget {
  final ProgressStep step;
  final AnimationController pulse;
  const _StepIcon({required this.step, required this.pulse});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (step == ProgressStep.done) {
      return Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primaryContainer,
        ),
        child: Icon(Icons.check_rounded, size: 52, color: colors.primary),
      );
    }

    if (step == ProgressStep.failed) {
      return Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.errorContainer,
        ),
        child: Icon(Icons.error_outline_rounded, size: 52, color: colors.error),
      );
    }

    return AnimatedBuilder(
      animation: pulse,
      builder: (_, __) => Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primaryContainer.withOpacity(0.5 + pulse.value * 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

class _StepsIndicator extends StatelessWidget {
  final ProgressStep current;
  const _StepsIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    final steps = [
      (ProgressStep.uploading, Icons.cloud_upload_rounded, 'رفع الملف'),
      (ProgressStep.processing, Icons.memory_rounded, 'معالجة البيانات'),
      (ProgressStep.done, Icons.task_alt_rounded, 'اكتمل'),
    ];

    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: steps.asMap().entries.map((entry) {
        final idx = entry.key;
        final step = entry.value;
        final isPast = current.index > step.$1.index;
        final isCurrent = current == step.$1;
        final isFailed =
            current == ProgressStep.failed && step.$1 == ProgressStep.done;

        Color iconColor;
        Color bgColor;
        if (isFailed && isCurrent) {
          iconColor = colors.onErrorContainer;
          bgColor = colors.errorContainer;
        } else if (isPast || isCurrent) {
          iconColor = colors.onPrimary;
          bgColor = colors.primary;
        } else {
          iconColor = colors.onSurfaceVariant;
          bgColor = colors.surfaceVariant;
        }

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration:
                      BoxDecoration(shape: BoxShape.circle, color: bgColor),
                  child: Icon(step.$2, size: 20, color: iconColor),
                ),
                const SizedBox(height: 6),
                Text(step.$3,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isCurrent || isPast
                              ? colors.primary
                              : colors.onSurfaceVariant,
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                        )),
              ],
            ),
            if (idx < steps.length - 1)
              Container(
                  width: 40,
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 20),
                  color: isPast ? colors.primary : colors.surfaceVariant),
          ],
        );
      }).toList(),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final ImportStatsModel stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatChip('الإجمالي', stats.totalStudents.toString(), colors.primary),
          _StatChip('ناجح', stats.successful.toString(), Colors.green),
          _StatChip('فشل', stats.failed.toString(), colors.error),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                )),
      ],
    );
  }
}

class _ErrorDetails extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorDetails({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            error,
            style: TextStyle(color: colors.onErrorContainer),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('حاول مجدداً'),
            style: OutlinedButton.styleFrom(foregroundColor: colors.error),
          ),
        ],
      ),
    );
  }
}
