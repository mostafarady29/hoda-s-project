// ===== File: lib/features/data_import/presentation/screens/import_excel_screen.dart =====

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/upload_cubit.dart';
import '../../../../data/models/import_status_model.dart';

// ── Department options
const List<Map<String, String>> kDepartments = [
  {'id': 'fine_arts', 'label': 'قسم التربية الفنية'},
  {'id': 'music', 'label': 'قسم التربية الموسيقية'},
  {'id': 'media', 'label': 'قسم الإعلام التربوي'},
  {'id': 'home_economics', 'label': 'قسم الاقتصاد المنزلي'},
  {'id': 'edu_tech', 'label': 'قسم تكنولوجيا التعليم والحاسب الآلي'},
  {'id': 'cs_english', 'label': 'برنامج إعداد معلم الحاسب الآلي (إنجليزي)'},
  {'id': 'digital_arts', 'label': 'برنامج إعداد معلم التربية الفنية الرقمية'},
];

class ImportExcelScreen extends StatefulWidget {
  final String? initialDepartment;

  const ImportExcelScreen({super.key, this.initialDepartment});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedDepartmentId;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _selectedDepartmentId = widget.initialDepartment;
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _startUpload() async {
    if (_selectedDepartmentId == null) {
      setState(() => _errorMessage = 'اختر القسم أولاً');
      return;
    }

    setState(() => _errorMessage = null);
    await context.read<UploadCubit>().pickAndUpload(_selectedDepartmentId!);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        title: const Text('استيراد السجل الأكاديمي'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colors.surface,
      ),
      body: BlocListener<UploadCubit, UploadState>(
        listener: (context, state) {
          if (state is UploadFailure) {
            setState(() => _errorMessage = state.message);
          }
          if (state is UploadCompleted) {
            Navigator.pushReplacementNamed(
              context,
              '/import_result',
              arguments: {
                'jobId': state.jobId,
                'index': state.index,
              },
            );
          }
        },
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _HeaderCard(colors: colors),
                  const SizedBox(height: 28),

                  Text('اختر القسم أو البرنامج',
                      style: text.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _DepartmentDropdown(
                    selectedDepartment: _selectedDepartmentId,
                    onChanged: (val) =>
                        setState(() => _selectedDepartmentId = val),
                  ),
                  const SizedBox(height: 28),

                  if (_errorMessage != null)
                    _ErrorBanner(message: _errorMessage!),

                  BlocBuilder<UploadCubit, UploadState>(
                    builder: (context, state) {
                      final isLoading =
                          state is UploadInProgress || state is UploadPolling;
                      return _SubmitButton(
                        isLoading: isLoading,
                        isEnabled: _selectedDepartmentId != null && !isLoading,
                        onPressed: _startUpload,
                        colors: colors,
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // ✅ شاشة التقدم مع وقت الانتظار
                  BlocBuilder<UploadCubit, UploadState>(
                    builder: (context, state) {
                      if (state is UploadPolling) {
                        final status = state.status;
                        final waitingSeconds = state.waitingTimeSeconds;

                        // ✅ حساب وقت الانتظار بالدقائق والثواني
                        final waitingMinutes = waitingSeconds ~/ 60;
                        final waitingSecondsRemainder = waitingSeconds % 60;
                        String waitingTimeText = '';
                        if (waitingMinutes > 0) {
                          waitingTimeText = 'انتظرت $waitingMinutes دقيقة';
                          if (waitingSecondsRemainder > 0) {
                            waitingTimeText +=
                                ' و $waitingSecondsRemainder ثانية';
                          }
                        } else if (waitingSeconds > 0) {
                          waitingTimeText = 'انتظرت $waitingSeconds ثانية';
                        }

                        // ✅ حساب نسبة التقدم
                        int progressPercent = 0;
                        if (status.stats.totalStudents > 0) {
                          progressPercent =
                              ((status.stats.successful + status.stats.failed) /
                                      status.stats.totalStudents *
                                      100)
                                  .toInt();
                          progressPercent = progressPercent.clamp(0, 100);
                        } else if (status.isProcessing) {
                          progressPercent = 50;
                        } else if (status.isCompleted ||
                            status.isPartialSuccess) {
                          progressPercent = 100;
                        }

                        // ✅ رسالة الحالة
                        String statusMessage;
                        if (status.isCompleted) {
                          statusMessage =
                              '✅ تم استيراد ${status.stats.successful} طالب بنجاح';
                          if (status.stats.failed > 0) {
                            statusMessage += ' (${status.stats.failed} فشل)';
                          }
                        } else if (status.isPartialSuccess) {
                          statusMessage =
                              '⚠️ تم الاستيراد مع تحذيرات: نجح ${status.stats.successful}، فشل ${status.stats.failed}';
                        } else if (status.isProcessing) {
                          statusMessage =
                              '🔄 جاري المعالجة... تم استيراد ${status.stats.successful} طالب حتى الآن';
                        } else if (status.isPending) {
                          statusMessage = '⏳ في انتظار بدء المعالجة...';
                        } else if (status.isFailed) {
                          statusMessage = '❌ فشلت المعالجة';
                          if (status.errorLog.isNotEmpty) {
                            statusMessage += ': ${status.errorLog.first}';
                          }
                        } else {
                          statusMessage = status.statusLabel;
                        }

                        return _ProgressCard(
                          progress: progressPercent,
                          message: statusMessage,
                          waitingTimeText: waitingTimeText,
                          colors: colors,
                          stats: status.stats,
                        );
                      }
                      if (state is UploadInProgress) {
                        return _ProgressCard(
                          progress: 0,
                          message: 'جاري رفع الملف...',
                          waitingTimeText: '',
                          colors: colors,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 24),
                  const _InfoSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final ColorScheme colors;
  const _HeaderCard({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.secondaryContainer,
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.table_chart_rounded, size: 56, color: colors.primary),
          const SizedBox(height: 12),
          Text(
            'استيراد السجل الأكاديمي',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'ارفع ملف Excel يحتوي على سجلات الطلاب\nسيتم تحليله تلقائياً بواسطة النظام الخبير',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DepartmentDropdown extends StatelessWidget {
  final String? selectedDepartment;
  final ValueChanged<String?>? onChanged;

  const _DepartmentDropdown({
    required this.selectedDepartment,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: selectedDepartment,
      hint: const Text('اختر القسم أو البرنامج'),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.school_rounded),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: kDepartments
          .map((d) => DropdownMenuItem(
                value: d['id'],
                child: Text(d['label']!),
              ))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;
  final ColorScheme colors;

  const _SubmitButton({
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isEnabled ? onPressed : null,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: colors.onPrimary),
            )
          : const Icon(Icons.cloud_upload_rounded),
      label: Text(
        isLoading ? 'جاري الرفع...' : 'اختر ملف Excel وارفع',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final int progress;
  final String message;
  final String waitingTimeText;
  final ColorScheme colors;
  final ImportStatsModel? stats;

  const _ProgressCard({
    required this.progress,
    required this.message,
    required this.waitingTimeText,
    required this.colors,
    this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: colors.surfaceContainerHighest,
            color: colors.primary,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(color: colors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '$progress%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.primary,
            ),
          ),

          // ✅ عرض وقت الانتظار
          if (waitingTimeText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              waitingTimeText,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'الملفات الكبيرة تحتاج وقت أطول للمعالجة',
              style: TextStyle(
                fontSize: 11,
                color: colors.onSurfaceVariant,
              ),
            ),
          ],

          // ✅ عرض الإحصائيات
          if (stats != null && (stats!.successful > 0 || stats!.failed > 0))
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text('${stats!.successful}',
                      style: const TextStyle(color: Colors.green)),
                  const SizedBox(width: 16),
                  Icon(Icons.error, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text('${stats!.failed}',
                      style: const TextStyle(color: Colors.red)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.security_rounded, 'ملفاتك آمنة ولا تُشارك مع أحد'),
      (Icons.speed_rounded, 'المعالجة تستغرق ثوانٍ معدودة'),
      (Icons.offline_bolt_rounded, 'النتائج تُحفظ محلياً للوصول بدون إنترنت'),
    ];

    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(item.$1,
                        size: 18, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(item.$2,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            )),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
