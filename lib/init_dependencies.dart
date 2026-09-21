import 'package:get_it/get_it.dart';
import 'package:salesman_tracking_app/data/datasources/auth_remote_datasource.dart';
import 'package:salesman_tracking_app/data/repositories/auth_repository_impl.dart';
import 'package:salesman_tracking_app/domain/repositories/auth_repository.dart';
import 'package:salesman_tracking_app/domain/usecases/get_current_user.dart';
import 'package:salesman_tracking_app/domain/usecases/login.dart';
import 'package:salesman_tracking_app/domain/usecases/logout.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External dependencies
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  _initAuth();
}

void _initAuth() {
  sl
    ..registerFactory<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(supabase: sl<SupabaseClient>()))
    ..registerFactory<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()))
    ..registerFactory<Login>(() => Login(sl<AuthRepository>()))
    ..registerFactory<Logout>(() => Logout(sl<AuthRepository>()))
    ..registerFactory<GetCurrentUser>(() => GetCurrentUser(sl<AuthRepository>()));
}
