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

    // ── Dio (HTTP client) - ✅ زيادة الـ Timeouts للملفات الكبيرة
    sl.registerLazySingleton<Dio>(() => Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(minutes: 5), // ✅ 15s → 5 دقائق
            receiveTimeout: const Duration(minutes: 10), // ✅ 60s → 10 دقائق
            sendTimeout: const Duration(minutes: 10), // ✅ 120s → 10 دقائق
          ),
        ));

    // ── Remote data sources
    sl.registerLazySingleton<UploadRemoteDataSource>(
        () => UploadRemoteDataSourceImpl(dio: sl()));

    sl.registerLazySingleton<JobRemoteDataSource>(
        () => JobRemoteDataSourceImpl(dio: sl()));

    sl.registerLazySingleton<StudentRemoteDataSource>(
        () => StudentRemoteDataSourceImpl(dio: sl()));

    // ── Mapper
    sl.registerLazySingleton<ImportMapper>(() => const ImportMapper());

    // ── Repositories
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

    // ── Use cases
    sl.registerLazySingleton(() => UploadExcelUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetJobStatusUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetStudentsIndexUseCase(repository: sl()));
    sl.registerLazySingleton(() => GetStudentDetailUseCase(repository: sl()));

    // ── Cubits (factory → new instance per screen)
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
