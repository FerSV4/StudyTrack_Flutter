import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/api_client.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/tasks/data/datasources/task_remote_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/repositories/task_repository.dart';
import 'features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'features/tasks/presentation/bloc/task_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // 1. Externos
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());

  // 2. Core
  sl.registerLazySingleton(() => ApiClient(dio: sl(), sharedPreferences: sl()));

  // 3. Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(apiClient: sl()),
  );

  // 4. Repositorios
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(remoteDataSource: sl()),
  );

  // 5. Casos de Uso
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetTasksUseCase(sl()));

  // 6. Blocs
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));
  sl.registerFactory(() => TaskBloc(getTasksUseCase: sl()));
}