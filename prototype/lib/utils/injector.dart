import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:prototype/data/datasource/user_datasource.dart';
import 'package:prototype/data/repositories/user_repo_imp.dart';
import 'package:prototype/domain/repositories/user_reposito.dart';
import 'package:prototype/domain/usecase/user_usecase.dart';
import 'package:prototype/presentation/login/bloc/login_bloc.dart';
import 'package:prototype/service/storage_service.dart';
import 'package:prototype/utils/dio_client.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Dio
  sl.registerLazySingleton<Dio>(() => DioClient.create());

  // Secure Storage
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  // Data Source
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: sl()),
  );

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserAuthRepositoryImpl(remoteDataSource: sl(), storage: sl()),
  );

  // UseCase
  sl.registerLazySingleton(() => UserUsecase(sl()));

  // Bloc
  sl.registerFactory(() => LoginBloc(userUsecase: sl()));

  // Service
  sl.registerLazySingleton<StorageService>(() => StorageService());
}
