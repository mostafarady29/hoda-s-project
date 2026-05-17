// ===== File: lib/features/data_import/presentation/screens/import_result_screen.dart =====

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/student_cubit.dart';
import '../cubit/upload_cubit.dart';
import '../../../../data/models/student_index_model.dart';
import '../../../../domain/entities/student.dart';

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
    return BlocProvider(
      create: (ctx) =>
          context.read<StudentCubit>()..loadStudentsList(jobId, index),
      child: _ImportResultView(jobId: jobId, index: index),
    );
  }
}

class _ImportResultView extends StatelessWidget {
  final String jobId;
  final StudentIndexModel index;

  const _ImportResultView({required this.jobId, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          title: Text(
            index.department != null
                ? 'طلاب ${index.department}'
                : 'نتائج الاستيراد',
          ),
          centerTitle: true,
          backgroundColor: colors.surface,
          elevation: 0,
          actions: [
            // Stats badge
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Chip(
                label: Text('${index.totalStudents} طالب'),
                backgroundColor: colors.primaryContainer,
                labelStyle: TextStyle(color: colors.onPrimaryContainer),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Warnings banner (partial success)
            if (index.hasErrors)
              _WarningsBanner(errorCount: index.errors.length),

            // Search bar
            _SearchBar(),

            // Students list
            Expanded(
              child: BlocBuilder<StudentCubit, StudentState>(
                builder: (context, state) {
                  if (state is StudentsListLoaded) {
                    final students = state.filtered;
                    if (students.isEmpty) {
                      return _EmptySearch();
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: students.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) => _StudentIndexCard(
                        item: students[i],
                        jobId: jobId,
                        index: index,
                      ),
                    );
                  }

                  if (state is StudentDetailLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is StudentDetailLoaded) {
                    return _StudentDetailView(
                        student: state.student, jobId: jobId, index: index);
                  }

                  if (state is StudentError) {
                    return _ErrorView(
                        message: state.message,
                        onRetry: () => context.read<StudentCubit>()
                          ..loadStudentsList(jobId, index));
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────

class _WarningsBanner extends StatelessWidget {
  final int errorCount;
  const _WarningsBanner({required this.errorCount});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: colors.errorContainer,
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: colors.onErrorContainer, size: 18),
          const SizedBox(width: 8),
          Text(
            'تعذّر قراءة $errorCount سجل — يمكنك المتابعة مع الطلاب المتاحين',
            style: TextStyle(color: colors.onErrorContainer, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: TextField(
        onChanged: (q) => context.read<StudentCubit>().search(q),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'ابحث بالاسم أو الرقم...',
          prefixIcon: const Icon(Icons.search_rounded),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

class _StudentIndexCard extends StatelessWidget {
  final StudentIndexItemModel item;
  final String jobId;
  final StudentIndexModel index;

  const _StudentIndexCard({
    required this.item,
    required this.jobId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          child: Text(
            item.name.isNotEmpty ? item.name[0] : '?',
            style: TextStyle(
                color: colors.onPrimaryContainer, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'رقم: ${item.studentId}',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 16, color: colors.primary),
        onTap: () => context
            .read<StudentCubit>()
            .loadStudentDetail(jobId, item.studentId),
      ),
    );
  }
}

class _StudentDetailView extends StatelessWidget {
  final Student student;
  final String jobId;
  final StudentIndexModel index;

  const _StudentDetailView({
    required this.student,
    required this.jobId,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Back button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () =>
                    context.read<StudentCubit>().backToList(jobId, index),
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('القائمة'),
              ),
            ],
          ),
        ),

        // Student info header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(student.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 6),
              _InfoRow('رقم الطالب', student.id, colors),
              _InfoRow('القسم', student.department, colors),
              _InfoRow('المستوى', student.studyLevel, colors),
              _InfoRow('آخر GPA', student.latestGpa.toStringAsFixed(2), colors),
              _InfoRow(
                  'إجمالي الساعات', '${student.totalPassedHours} ساعة', colors),
            ],
          ),
        ),

        // Semesters
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: student.semesters.length,
            itemBuilder: (ctx, i) => _SemesterCard(
              semester: student.semesters[i],
              index: i + 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme colors;

  const _InfoRow(this.label, this.value, this.colors);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ',
              style: TextStyle(
                  color: colors.onPrimaryContainer.withOpacity(0.7),
                  fontSize: 13)),
          Text(value,
              style: TextStyle(
                  color: colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  final dynamic semester; // Semester entity
  final int index;

  const _SemesterCard({required this.semester, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: colors.surfaceVariant,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: colors.secondaryContainer,
          radius: 18,
          child: Text('$index',
              style: TextStyle(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
        title: Text(
          semester.levelSemester.isNotEmpty
              ? semester.levelSemester
              : 'الفصل $index',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${semester.academicYear} • GPA: ${semester.gpa.toStringAsFixed(2)}',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),
        children: [
          if (semester.courses.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('لا توجد مواد',
                  style: TextStyle(color: colors.onSurfaceVariant)),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                headingRowHeight: 36,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 48,
                columns: const [
                  DataColumn(label: Text('م')),
                  DataColumn(label: Text('المادة')),
                  DataColumn(label: Text('الساعات')),
                  DataColumn(label: Text('الدرجة')),
                  DataColumn(label: Text('الحالة')),
                ],
                rows: (semester.courses as List).map<DataRow>((course) {
                  final passed = course.isPassed as bool;
                  return DataRow(cells: [
                    DataCell(Text(course.seq.toString())),
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          course.courseName.toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(course.hours.toString())),
                    DataCell(Text(course.gradeLetter.toString())),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: passed
                              ? Colors.green.withOpacity(0.15)
                              : colors.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          passed ? 'ناجح' : 'راسب',
                          style: TextStyle(
                            color:
                                passed ? Colors.green.shade800 : colors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded,
              size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text('لا توجد نتائج مطابقة',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}
