import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/tasks/data/datasources/task_remote_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/domain/usecases/create_task_usecase.dart';
import 'features/tasks/domain/usecases/delete_task_usecase.dart';
import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'features/tasks/domain/usecases/update_task_usecase.dart';
import 'features/tasks/domain/usecases/update_task_status_usecase.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';

import 'features/academic/data/datasources/academic_remote_data_source.dart';
import 'features/academic/data/repositories/academic_repository_impl.dart';
import 'features/academic/domain/repositories/academic_repository.dart';
import 'features/academic/domain/usecases/create_subject_usecase.dart';
import 'features/academic/domain/usecases/create_term_usecase.dart';
import 'features/academic/domain/usecases/get_active_term_usecase.dart';
import 'features/academic/presentation/bloc/academic_bloc.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile_usecase.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';

import 'features/study_sessions/data/datasources/study_session_remote_data_source.dart';
import 'features/study_sessions/data/repositories/study_session_repository_impl.dart';
import 'features/study_sessions/domain/repositories/study_session_repository.dart';
import 'features/study_sessions/domain/usecases/finish_session_usecase.dart';
import 'features/study_sessions/domain/usecases/start_session_usecase.dart';
import 'features/study_sessions/presentation/bloc/study_session_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Externos
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());

  // 2. Core
  sl.registerLazySingleton(() => ApiClient(dio: sl(), sharedPreferences: sl()));

  // 3. Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<TaskRemoteDataSource>(() => TaskRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<AcademicRemoteDataSource>(() => AcademicRemoteDataSource(apiClient: sl()));
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<StudySessionRemoteDataSource>(() => StudySessionRemoteDataSourceImpl(apiClient: sl()));

  // 4. Repositorios
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<AcademicRepository>(() => AcademicRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<StudySessionRepository>(() => StudySessionRepositoryImpl(remoteDataSource: sl()));

  // 5. Casos de Uso
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskStatusUseCase(sl()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveTermUseCase(sl()));
  sl.registerLazySingleton(() => CreateTermUseCase(sl()));
  sl.registerLazySingleton(() => CreateSubjectUseCase(sl()));
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => StartSessionUseCase(sl()));
  sl.registerLazySingleton(() => FinishSessionUseCase(sl()));

  // 6. Blocs
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), registerUseCase: sl()));
  sl.registerFactory(() => TaskBloc(
        getTasksUseCase: sl(),
        updateTaskStatusUseCase: sl(),
        createTaskUseCase: sl(),
        updateTaskUseCase: sl(),
        deleteTaskUseCase: sl(),
      ));
  sl.registerFactory(() => AcademicBloc(
        getActiveTermUseCase: sl(),
        createTermUseCase: sl(),
        createSubjectUseCase: sl(),
      ));
  sl.registerFactory(() => ProfileBloc(getProfileUseCase: sl()));
  sl.registerFactory(() => StudySessionBloc(
        startSessionUseCase: sl(),
        finishSessionUseCase: sl(),
      ));
}
