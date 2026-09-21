import 'package:fpdart/fpdart.dart';

import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/data/datasources/auth_remote_datasource.dart';
import 'package:salesman_tracking_app/domain/entities/user.dart';
import 'package:salesman_tracking_app/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<TFailure, User>> login({required String email, required String password}) async {
    try {
      final user = await remoteDataSource.login(email: email, password: password);

      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, User?>> getCurrentUser() async {
    try {
      final user = await remoteDataSource.getCurrentUser();

      return Right(user);
    } catch (e) {
      return Left(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, void>> logout() async {
    try {
      await remoteDataSource.logout();

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
