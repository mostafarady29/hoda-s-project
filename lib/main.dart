// ===== File: lib/main.dart =====

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/providers/dependency_injection.dart';

import 'features/data_import/presentation/cubit/upload_cubit.dart';
import 'features/data_import/presentation/cubit/student_cubit.dart';
import 'features/data_import/presentation/screens/import_excel_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize service locator
  await DependencyInjection.init();

  runApp(const AcadexaApp());
}

class AcadexaApp extends StatelessWidget {
  const AcadexaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UploadCubit>(
          create: (_) => sl<UploadCubit>(),
        ),
        BlocProvider<StudentCubit>(
          create: (_) => sl<StudentCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Acadexa',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        // ✅ إزالة onUpload لأنه مش موجود في الـ constructor الجديد
        home: const ImportExcelScreen(),
      ),
    );
  }
}
