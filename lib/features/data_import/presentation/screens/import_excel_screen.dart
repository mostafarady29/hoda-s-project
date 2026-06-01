// lib/features/data_import/presentation/screens/import_excel_screen.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_shadows.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/themes/app_theme.dart';
import '../cubit/upload_cubit.dart';
import 'import_result_screen.dart'; // ✅ أضيفي هذا الاستيراد

const List<Map<String, String>> kDepartments = [
  {'id': 'fine_arts', 'label': 'التربية الفنية'},
  {'id': 'music', 'label': 'التربية الموسيقية'},
  {'id': 'media', 'label': 'الإعلام التربوي'},
  {'id': 'home_economics', 'label': 'الاقتصاد المنزلي'},
  {'id': 'edu_tech', 'label': 'تكنولوجيا التعليم والحاسب الآلي'},
  {'id': 'cs_english', 'label': 'إعداد معلم الحاسب الآلي (إنجليزي)'},
  {'id': 'digital_arts', 'label': 'إعداد معلم التربية الفنية الرقمية'},
];

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen>
    with SingleTickerProviderStateMixin {
  PlatformFile? _pickedFile;
  String? _selectedDeptId;
  String? _errorMessage;

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    setState(() => _errorMessage = null);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final file = result.files.single;
      if (file.size > 50 * 1024 * 1024) {
        setState(() => _errorMessage = 'حجم الملف يتجاوز الحد الأقصى (50 MB)');
        return;
      }
      setState(() => _pickedFile = file);
    } catch (_) {
      setState(() => _errorMessage = 'فشل اختيار الملف');
    }
  }

  void _submit() {
    if (_pickedFile == null) {
      setState(() => _errorMessage = 'يرجى اختيار ملف Excel أولاً');
      return;
    }
    if (_selectedDeptId == null) {
      setState(() => _errorMessage = 'يرجى اختيار القسم أو البرنامج');
      return;
    }
    setState(() => _errorMessage = null);
    context.read<UploadCubit>().uploadPlatformFile(_pickedFile!, _selectedDeptId!);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    final isWide =
        MediaQuery.of(context).size.width >= AppTheme.tabletBreakpoint;

    return BlocListener<UploadCubit, UploadState>(
      listener: (context, state) {
        if (state is UploadFailure) {
          setState(() => _errorMessage = state.message);
        }
        // ✅ ✅ ✅ الجزء المطلوب ✅ ✅ ✅
        if (state is UploadCompleted) {
          print('✅ Upload completed! Navigating to result screen...');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ImportResultScreen(
                jobId: state.jobId,
                index: state.index,
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: isWide ? _buildWide(isDark) : _buildNarrow(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWide(bool isDark) {
    return Row(
      children: [
        Expanded(flex: 5, child: _HeroPanel(isDark: isDark)),
        Expanded(
          flex: 6,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingXXL),
            child: _buildForm(isDark),
          ),
        ),
      ],
    );
  }

  Widget _buildNarrow(bool isDark) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: const _CompactHero()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMD,
            AppTheme.spacingLG,
            AppTheme.spacingMD,
            AppTheme.spacingXXL,
          ),
          sliver: SliverToBoxAdapter(child: _buildForm(isDark)),
        ),
      ],
    );
  }

  Widget _buildForm(bool isDark) {
    return BlocBuilder<UploadCubit, UploadState>(
      builder: (context, state) {
        final isLoading = state is UploadInProgress;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'استيراد السجل الأكاديمي',
              style: AppTextStyles.headlineSmall.copyWith(
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXS),
            Text(
              'ارفع ملف Excel الخاص بالقسم لبدء التحليل التلقائي',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXL),
            _StepLabel(number: '١', label: 'اختر ملف Excel', isDark: isDark),
            const SizedBox(height: AppTheme.spacingSM),
            _FilePickerCard(
              pickedFile: _pickedFile,
              onTap: isLoading ? null : _pickFile,
              isDark: isDark,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            _StepLabel(
              number: '٢',
              label: 'اختر القسم أو البرنامج',
              isDark: isDark,
            ),
            const SizedBox(height: AppTheme.spacingSM),
            _DepartmentSelector(
              selected: _selectedDeptId,
              onChanged: (v) {
                if (!isLoading) {
                  setState(() => _selectedDeptId = v);
                }
              },
              isDark: isDark,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            if (_errorMessage != null) ...[
              _ErrorBanner(message: _errorMessage!),
              const SizedBox(height: AppTheme.spacingMD),
            ],
            _SubmitButton(
              isLoading: isLoading,
              isEnabled:
                  _pickedFile != null && _selectedDeptId != null && !isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: AppTheme.spacingXL),
            const _InfoFooter(),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// Hero Panel (wide screens)
// ─────────────────────────────────────────────
class _HeroPanel extends StatelessWidget {
  final bool isDark;
  const _HeroPanel({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
            ),
            child:
                const Icon(Icons.school_rounded, color: Colors.white, size: 36),
          ),
          const SizedBox(height: AppTheme.spacingXL),
          Text(
            'أكاديكسا',
            style: AppTextStyles.displaySmall
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppTheme.spacingSM),
          Text(
            'نظام الإرشاد الأكاديمي الذكي\nكلية التربية النوعية\nجامعة كفرالشيخ',
            style: AppTextStyles.bodyLarge.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.8,
            ),
          ),
          const SizedBox(height: AppTheme.spacingXXL),
          ...[
            (Icons.analytics_rounded, 'تحليل السجل الأكاديمي تلقائياً'),
            (Icons.warning_amber_rounded, 'كشف المشكلات قبل وقوعها'),
            (Icons.picture_as_pdf_rounded, 'تقارير احترافية قابلة للتصدير'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMD),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: Icon(item.$1, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: AppTheme.spacingMD),
                  Text(
                    item.$2,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Compact Hero (mobile)
// ─────────────────────────────────────────────
class _CompactHero extends StatelessWidget {
  const _CompactHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.spacingXL),
          bottomRight: Radius.circular(AppTheme.spacingXL),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingLG,
        AppTheme.spacingXL,
        AppTheme.spacingLG,
        AppTheme.spacingXL,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child:
                const Icon(Icons.school_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppTheme.spacingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'أكاديكسا',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'استيراد وتحليل السجلات الأكاديمية',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable sub-widgets
// ─────────────────────────────────────────────

class _StepLabel extends StatelessWidget {
  final String number;
  final String label;
  final bool isDark;

  const _StepLabel({
    required this.number,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primaryMain,
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSM),
        Text(
          label,
          style: AppTextStyles.titleSmall.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FilePickerCard extends StatelessWidget {
  final PlatformFile? pickedFile;
  final VoidCallback? onTap;
  final bool isDark;

  const _FilePickerCard({
    required this.pickedFile,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = pickedFile != null;
    final fileName = pickedFile?.name ?? '';

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(AppTheme.spacingMD),
        decoration: BoxDecoration(
          color: hasFile
              ? AppColors.primaryMain.withValues(alpha: 0.05)
              : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          border: Border.all(
            color: hasFile
                ? AppColors.primaryMain
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: hasFile ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          boxShadow: hasFile ? AppShadows.soft : [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasFile
                    ? AppColors.primaryMain.withValues(alpha: 0.1)
                    : (isDark
                        ? AppColors.surfaceVariantDark
                        : AppColors.surfaceVariantLight),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Icon(
                hasFile ? Icons.description_rounded : Icons.upload_file_rounded,
                color: hasFile
                    ? AppColors.primaryMain
                    : (isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight),
                size: 24,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasFile ? 'تم اختيار الملف' : 'اضغط لاختيار ملف',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: hasFile
                          ? AppColors.primaryMain
                          : (isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile ? fileName : 'xlsx, xls — حتى 50 MB',
                    style: AppTextStyles.captionMedium.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.swap_horiz_rounded : Icons.chevron_left_rounded,
              color: hasFile
                  ? AppColors.primaryMain
                  : (isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _DepartmentSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?>? onChanged;
  final bool isDark;

  const _DepartmentSelector({
    required this.selected,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMD),
            child: Text(
              'اختر القسم أو البرنامج',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textTertiaryDark
                    : AppColors.textTertiaryLight,
              ),
            ),
          ),
          isExpanded: true,
          icon: Padding(
            padding: const EdgeInsets.only(left: AppTheme.spacingMD),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
          dropdownColor:
              isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          style: AppTextStyles.bodyMedium.copyWith(
            color:
                isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingSM,
          ),
          items: kDepartments.map((dept) {
            return DropdownMenuItem<String>(
              value: dept['id'],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMD,
                ),
                child: Text(dept['label']!),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppColors.errorMain.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.errorMain, size: 20),
          const SizedBox(width: AppTheme.spacingSM),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.errorDark,
                fontWeight: FontWeight.w500,
              ),
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

  const _SubmitButton({
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: isEnabled ? AppColors.primaryGradient : null,
        color: isEnabled ? null : AppColors.disabledLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        boxShadow: isEnabled ? AppShadows.academicCard : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.spacingMD,
              horizontal: AppTheme.spacingLG,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                else
                  const Icon(Icons.cloud_upload_rounded,
                      color: Colors.white, size: 20),
                const SizedBox(width: AppTheme.spacingSM),
                Text(
                  isLoading ? 'جاري الرفع...' : 'رفع وتحليل الملف',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoFooter extends StatelessWidget {
  const _InfoFooter();

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDarkMode(context);
    final items = [
      (Icons.lock_outline_rounded, 'ملفاتك آمنة ولا تُشارك مع أحد'),
      (Icons.speed_rounded, 'المعالجة تستغرق ثوانٍ معدودة'),
      (Icons.offline_bolt_rounded, 'النتائج تُحفظ محلياً للوصول بدون إنترنت'),
    ];
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
              child: Row(
                children: [
                  Icon(item.$1, size: 16, color: AppColors.tealHighlight),
                  const SizedBox(width: AppTheme.spacingSM),
                  Text(
                    item.$2,
                    style: AppTextStyles.captionMedium.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
