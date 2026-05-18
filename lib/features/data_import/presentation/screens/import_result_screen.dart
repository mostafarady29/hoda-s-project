// lib/features/data_import/presentation/screens/import_result_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_shadows.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../data/models/student_index_model.dart';
import '../../../../domain/entities/course.dart';
import '../../../../domain/entities/semester.dart';
import '../../../../domain/entities/student.dart';
import '../cubit/student_cubit.dart';

class ImportResultScreen extends StatelessWidget {
  final String jobId;
  final StudentIndexModel index;

  const ImportResultScreen({
    super.key,
    required this.jobId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentCubit>().loadStudentsList(jobId, index);
    });

    final isDark = AppTheme.isDarkMode(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: BlocBuilder<StudentCubit, StudentState>(
          builder: (context, state) {
            if (state is StudentsListLoaded) {
              return _StudentsListView(
                jobId: jobId,
                index: index,
                state: state,
                isDark: isDark,
              );
            }
            if (state is StudentDetailLoading) {
              return _LoadingDetailView(
                  studentId: state.studentId, isDark: isDark);
            }
            if (state is StudentDetailLoaded) {
              return _StudentDetailView(
                student: state.student,
                jobId: jobId,
                index: index,
                isDark: isDark,
              );
            }
            if (state is StudentError) {
              return _ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<StudentCubit>().loadStudentsList(jobId, index),
                isDark: isDark,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Students List
// ─────────────────────────────────────────────
class _StudentsListView extends StatelessWidget {
  final String jobId;
  final StudentIndexModel index;
  final StudentsListLoaded state;
  final bool isDark;

  const _StudentsListView({
    required this.jobId,
    required this.index,
    required this.state,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final deptLabel = _deptLabel(index.department);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 140,
          pinned: true,
          backgroundColor:
              isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.primaryGradient),
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMD,
                AppTheme.spacingXXL,
                AppTheme.spacingMD,
                AppTheme.spacingMD,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    deptLabel,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    '${index.totalStudents} طالب — ${state.filtered.length} ظاهر',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (index.hasErrors)
          SliverToBoxAdapter(
            child:
                _WarningBanner(errorCount: index.errors.length, isDark: isDark),
          ),
        SliverToBoxAdapter(
          child: _StatsRow(index: index, isDark: isDark),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SearchBarDelegate(isDark: isDark),
        ),
        state.filtered.isEmpty
            ? SliverFillRemaining(
                child: _EmptySearch(isDark: isDark),
              )
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMD,
                  AppTheme.spacingXS,
                  AppTheme.spacingMD,
                  AppTheme.spacingXXL,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _StudentCard(
                      item: state.filtered[i],
                      index: i,
                      jobId: jobId,
                      isDark: isDark,
                    ),
                    childCount: state.filtered.length,
                  ),
                ),
              ),
      ],
    );
  }

  String _deptLabel(String? id) {
    const map = {
      'fine_arts': 'قسم التربية الفنية',
      'music': 'قسم التربية الموسيقية',
      'media': 'قسم الإعلام التربوي',
      'home_economics': 'قسم الاقتصاد المنزلي',
      'edu_tech': 'قسم تكنولوجيا التعليم',
      'cs_english': 'برنامج الحاسب الآلي (إنجليزي)',
      'digital_arts': 'برنامج التربية الفنية الرقمية',
    };
    return map[id] ?? id ?? 'الطلاب';
  }
}

// ✅ ✅ ✅ الجزء المصحح من _SearchBarDelegate ✅ ✅ ✅
class _SearchBarDelegate extends SliverPersistentHeaderDelegate {
  final bool isDark;
  const _SearchBarDelegate({required this.isDark});

  @override
  double get minExtent => 56.0;
  @override
  double get maxExtent => 56.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: 56.0,
      child: Container(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMD,
          vertical: AppTheme.spacingXS,
        ),
        child: TextField(
          onChanged: (q) => context.read<StudentCubit>().search(q),
          textDirection: TextDirection.rtl,
          decoration: InputDecoration(
            hintText: 'ابحث بالاسم أو رقم الطالب...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
              size: 20,
            ),
            filled: true,
            fillColor:
                isDark ? AppColors.surfaceDark : AppColors.surfaceVariantLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMD,
              vertical: AppTheme.spacingSM,
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SearchBarDelegate old) => old.isDark != isDark;
}

class _WarningBanner extends StatelessWidget {
  final int errorCount;
  final bool isDark;
  const _WarningBanner({required this.errorCount, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        AppTheme.spacingMD,
        AppTheme.spacingMD,
        0,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: AppColors.warningMain.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.warningMain, size: 20),
          const SizedBox(width: AppTheme.spacingSM),
          Expanded(
            child: Text(
              'تعذّر قراءة $errorCount سجل — يمكنك المتابعة مع الطلاب المتاحين',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.warningDark,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final StudentIndexModel index;
  final bool isDark;
  const _StatsRow({required this.index, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        AppTheme.spacingMD,
        AppTheme.spacingMD,
        0,
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.people_rounded,
            value: '${index.totalStudents}',
            label: 'إجمالي الطلاب',
            color: AppColors.primaryMain,
            isDark: isDark,
          ),
          const SizedBox(width: AppTheme.spacingSM),
          _StatChip(
            icon: Icons.check_circle_rounded,
            value: '${index.students.length}',
            label: 'تمت قراءتهم',
            color: AppColors.successMain,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMD,
        vertical: AppTheme.spacingSM,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: AppTheme.spacingXS),
          Text(
            '$value $label',
            style: AppTextStyles.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ],
      ),
    );
  }
}

// ✅ _StudentCard مع RTL (الصورة على اليمين، السهم على اليسار)
class _StudentCard extends StatelessWidget {
  final StudentIndexItemModel item;
  final int index;
  final String jobId;
  final bool isDark;

  const _StudentCard({
    required this.item,
    required this.index,
    required this.jobId,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSM),
      child: Material(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLG),
          onTap: () => context
              .read<StudentCubit>()
              .loadStudentDetail(jobId, item.studentId),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMD),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
              border: Border.all(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
              ),
              boxShadow: isDark ? [] : AppShadows.soft,
            ),
            child: Row(
              children: [
                // السهم على اليسار
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                  size: 16,
                ),
                const SizedBox(width: AppTheme.spacingMD),
                // معلومات الطالب
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.studentId,
                        style: AppTextStyles.captionMedium.copyWith(
                          fontFamily: 'monospace',
                          color: isDark
                              ? AppColors.textTertiaryDark
                              : AppColors.textTertiaryLight,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMD),
                // الصورة على اليمين
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    item.name.isNotEmpty ? item.name[0] : '؟',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
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

class _EmptySearch extends StatelessWidget {
  final bool isDark;
  const _EmptySearch({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.surfaceVariantDark
                  : AppColors.surfaceVariantLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 36,
              color: isDark
                  ? AppColors.textTertiaryDark
                  : AppColors.textTertiaryLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Text(
            'لا توجد نتائج مطابقة',
            style: AppTextStyles.titleSmall.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Loading detail placeholder
// ─────────────────────────────────────────────
class _LoadingDetailView extends StatelessWidget {
  final String studentId;
  final bool isDark;
  const _LoadingDetailView({required this.studentId, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        leading: BackButton(
          onPressed: () => context.read<StudentCubit>().loadStudentsList(
                '',
                StudentIndexModel(
                  jobId: '',
                  status: '',
                  totalStudents: 0,
                  students: [],
                  errors: [],
                ),
              ),
        ),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

// ─────────────────────────────────────────────
// Student Detail View
// ─────────────────────────────────────────────
class _StudentDetailView extends StatelessWidget {
  final Student student;
  final String jobId;
  final StudentIndexModel index;
  final bool isDark;

  const _StudentDetailView({
    required this.student,
    required this.jobId,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () =>
                context.read<StudentCubit>().backToList(jobId, index),
          ),
          backgroundColor: AppColors.primaryDeep,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.primaryGradient),
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingMD,
                80,
                AppTheme.spacingMD,
                AppTheme.spacingMD,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    student.name,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.end,
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    student.id,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontFamily: 'monospace',
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _StudentQuickStats(student: student, isDark: isDark),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMD,
            0,
            AppTheme.spacingMD,
            AppTheme.spacingXXL,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => _SemesterAccordion(
                semester: student.semesters[i],
                semesterNumber: i + 1,
                isDark: isDark,
              ),
              childCount: student.semesters.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentQuickStats extends StatelessWidget {
  final Student student;
  final bool isDark;
  const _StudentQuickStats({required this.student, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final gpa = student.latestGpa;
    Color gpaColor;
    if (gpa >= 3.5)
      gpaColor = AppColors.gpaExcellent;
    else if (gpa >= 3.0)
      gpaColor = AppColors.gpaGood;
    else if (gpa >= 2.5)
      gpaColor = AppColors.gpaSatisfactory;
    else if (gpa >= 2.0)
      gpaColor = AppColors.gpaWarning;
    else
      gpaColor = AppColors.gpaProbation;

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMD),
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: isDark ? [] : AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickStat(
            value: gpa.toStringAsFixed(2),
            label: 'آخر GPA',
            valueColor: gpaColor,
            isDark: isDark,
          ),
          const _VerticalDivider(),
          _QuickStat(
            value: '${student.totalPassedHours}',
            label: 'ساعات مجتازة',
            valueColor: AppColors.primaryMain,
            isDark: isDark,
          ),
          const _VerticalDivider(),
          _QuickStat(
            value: '${student.semesters.length}',
            label: 'فصول دراسية',
            valueColor: AppColors.tealHighlight,
            isDark: isDark,
          ),
          const _VerticalDivider(),
          _QuickStat(
            value: '${student.failedCourses.length}',
            label: 'مواد راسبة',
            valueColor: student.failedCourses.isEmpty
                ? AppColors.successMain
                : AppColors.errorMain,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;
  final bool isDark;

  const _QuickStat({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.headlineSmall.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: isDark
                ? AppColors.textTertiaryDark
                : AppColors.textTertiaryLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.borderLight,
    );
  }
}

class _SemesterAccordion extends StatelessWidget {
  final Semester semester;
  final int semesterNumber;
  final bool isDark;

  const _SemesterAccordion({
    required this.semester,
    required this.semesterNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final hasFailures = semester.hasFailures;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSM),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLG),
        border: Border.all(
          color: hasFailures
              ? AppColors.warningMain.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        boxShadow: isDark ? [] : AppShadows.soft,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMD,
            vertical: AppTheme.spacingXS,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: hasFailures
                  ? AppColors.warningGradient
                  : AppColors.heroGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            alignment: Alignment.center,
            child: Text(
              '$semesterNumber',
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          title: Text(
            semester.levelSemester.isNotEmpty
                ? semester.levelSemester
                : 'الفصل $semesterNumber',
            style: AppTextStyles.labelLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.end,
          ),
          subtitle: Row(
            children: [
              Text(
                semester.academicYear,
                style: AppTextStyles.captionMedium.copyWith(
                  color: isDark
                      ? AppColors.textTertiaryDark
                      : AppColors.textTertiaryLight,
                ),
                textAlign: TextAlign.end,
              ),
              const SizedBox(width: AppTheme.spacingSM),
              _GpaBadge(gpa: semester.gpa),
              if (hasFailures) ...[
                const SizedBox(width: AppTheme.spacingXS),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.errorBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                  ),
                  child: Text(
                    '${semester.failedCourses.length} راسب',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.errorMain,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ],
          ),
          children: [
            if (semester.courses.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMD),
                child: Text(
                  'لا توجد مواد مسجلة في هذا الفصل',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              _CoursesTable(courses: semester.courses, isDark: isDark),
          ],
        ),
      ),
    );
  }
}

class _GpaBadge extends StatelessWidget {
  final double gpa;
  const _GpaBadge({required this.gpa});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (gpa >= 3.5)
      color = AppColors.gpaExcellent;
    else if (gpa >= 3.0)
      color = AppColors.gpaGood;
    else if (gpa >= 2.5)
      color = AppColors.gpaSatisfactory;
    else if (gpa >= 2.0)
      color = AppColors.gpaWarning;
    else
      color = AppColors.gpaProbation;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusXS),
      ),
      child: Text(
        'GPA: ${gpa.toStringAsFixed(2)}',
        style: AppTextStyles.captionSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _CoursesTable extends StatelessWidget {
  final List<Course> courses;
  final bool isDark;
  const _CoursesTable({required this.courses, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        0,
        AppTheme.spacingMD,
        AppTheme.spacingMD,
      ),
      child: DataTable(
        columnSpacing: AppTheme.spacingMD,
        headingRowHeight: 40,
        dataRowMinHeight: 36,
        dataRowMaxHeight: 44,
        headingRowColor: WidgetStateProperty.all(
          isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
        ),
        border: TableBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          horizontalInside: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.5,
          ),
        ),
        columns: [
          _col('م'),
          _col('الكود'),
          _col('اسم المادة'),
          _col('ساعات'),
          _col('الدرجة'),
          _col('التقدير'),
          _col('الحالة'),
        ],
        rows: courses.map((course) {
          final passed = course.isPassed;
          return DataRow(
            color: WidgetStateProperty.resolveWith((states) {
              if (!passed) {
                return AppColors.errorBg.withValues(alpha: 0.4);
              }
              return null;
            }),
            cells: [
              _cell(course.seq),
              DataCell(
                Text(
                  course.courseCode,
                  style: AppTextStyles.courseCode,
                ),
              ),
              DataCell(
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 200),
                  child: Text(
                    course.courseName,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
              _cell('${course.hours}'),
              _cell(course.score > 0 ? course.score.toStringAsFixed(0) : '-'),
              _cell(course.gradeLetter),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXS,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: passed ? AppColors.successBg : AppColors.errorBg,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXS),
                  ),
                  child: Text(
                    passed ? 'ناجح' : 'راسب',
                    style: AppTextStyles.captionSmall.copyWith(
                      color:
                          passed ? AppColors.successDark : AppColors.errorDark,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  DataColumn _col(String label) => DataColumn(
        label: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  DataCell _cell(String value) => DataCell(
        Text(value, style: AppTextStyles.bodySmall),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;

  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.errorBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: AppColors.errorMain, size: 40),
              ),
              const SizedBox(height: AppTheme.spacingLG),
              Text(
                'حدث خطأ',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppTheme.spacingSM),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.spacingXL),
              ElevatedButton.icon(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryMain,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXL,
                    vertical: AppTheme.spacingMD,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
