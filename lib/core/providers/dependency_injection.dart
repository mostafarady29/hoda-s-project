// ===== File: lib/core/providers/dependency_injection.dart =====

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../constants/api_endpoints.dart';
import '../services/storage/hive_storage_service.dart';
import '../../data/datasources/remote/upload_remote_data_source.dart';
import '../../data/datasources/remote/job_remote_data_source.dart';
import '../../data/datasources/remote/student_remote_data_source.dart';
import '../../data/mappers/import_mapper.dart';
import '../../data/repositories/upload_repository_impl.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../domain/repositories/upload_repository.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/usecases/upload_excel.dart';
import '../../domain/usecases/get_job_status.dart';
import '../../domain/usecases/get_students_index.dart';
import '../../domain/usecases/get_student_detail.dart';
import '../../features/data_import/presentation/cubit/upload_cubit.dart';
import '../../features/data_import/presentation/cubit/student_cubit.dart';

final sl = GetIt.instance;

class DependencyInjection {
  DependencyInjection._();

  static Future<void> init() async {
    // ── Storage
    await HiveStorageService.instance.init();
    sl.registerSingleton<HiveStorageService>(HiveStorageService.instance);

    // ── Dio (HTTP client) - ✅ مع Interceptor
    sl.registerLazySingleton<Dio>(() {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 10),
          sendTimeout: const Duration(minutes: 10),
        ),
      );

      // ✅ ✅ ✅ Interceptor عشان نشوف الخطأ
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('🚀 REQUEST: ${options.method} ${options.uri}');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('✅ RESPONSE: ${response.statusCode}');
            print('📦 DATA: ${response.data}');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            return handler.next(response);
          },
          onError: (error, handler) {
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            print('❌ ERROR: ${error.type}');
            print('📝 MESSAGE: ${error.message}');
            print('🔢 STATUS: ${error.response?.statusCode}');
            print('📄 RESPONSE: ${error.response?.data}');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            return handler.next(error);
          },
        ),
      );

      return dio;
    });

    // ── Remote data sources (باقي الكود زي ما هو)
    sl.registerLazySingleton<UploadRemoteDataSource>(
        () => UploadRemoteDataSourceImpl(dio: sl()));

    sl.registerLazySingleton<JobRemoteDataSource>(
        () => JobRemoteDataSourceImpl(dio: sl()));

    sl.registerLazySingleton<StudentRemoteDataSource>(
        () => StudentRemoteDataSourceImpl(dio: sl()));

    sl.registerLazySingleton<ImportMapper>(() => const ImportMapper());

    sl.registerLazySingleton<UploadRepository>(
      () => UploadRepositoryImpl(
        uploadDataSource: sl(),
        jobDataSource: sl(),
        studentDataSource: sl(),
      ),
    );

    sl.registerLazySingleton<StudentRepository>(
      () => StudentRepositoryImpl(
        remoteDataSource: sl(),
        mapper: sl(),
        storage: sl(),
      ),
    );

    sl.registerLazySingleton(() => UploadExcelUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetJobStatusUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetStudentsIndexUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetStudentDetailUseCase(repository: sl()));

    sl.registerFactory(
      () => UploadCubit(
        uploadExcel: sl(),
        getJobStatus: sl(),
        getStudentsIndex: sl(),
      ),
    );

    sl.registerFactory(
      () => StudentCubit(getStudentDetail: sl()),
    );
  }
}
