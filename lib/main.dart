// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ أضيفي هذا الاستيراد

import 'core/providers/dependency_injection.dart';
import 'features/data_import/presentation/cubit/upload_cubit.dart';
import 'features/data_import/presentation/cubit/student_cubit.dart';
import 'features/data_import/presentation/screens/import_excel_screen.dart';
import 'features/data_import/presentation/screens/import_result_screen.dart';
import 'features/academic_advisor/presentation/screens/student_profile_screen.dart';
import 'data/models/student_index_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
        locale: const Locale('ar', 'EG'),
        supportedLocales: const [
          Locale('ar', 'EG'), // العربية
          Locale('en', 'US'), // الإنجليزية (احتياطي)
        ],
        // ✅ ✅ ✅ أضيفي هذه الأسطر الثلاثة ✅ ✅ ✅
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        initialRoute: '/',
        routes: {
          '/': (context) => const ImportExcelScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/import_result') {
            final args = settings.arguments as Map;
            return MaterialPageRoute(
              builder: (_) => ImportResultScreen(
                jobId: args['jobId'] as String,
                index: args['index'] as StudentIndexModel,
              ),
            );
          }
          if (settings.name == '/student_profile') {
            final args = settings.arguments as Map;
            return MaterialPageRoute(
              builder: (_) => StudentProfileScreen(
                studentId: args['studentId'] as String,
                jobId: args['jobId'] as String,
              ),
            );
          }
          return MaterialPageRoute(
            builder: (_) => const ImportExcelScreen(),
          );
        },
      ),
    );
  }
}
