import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/data/datasources/user_remote_datasource.dart';
import 'package:salesman_tracking_app/domain/entities/user.dart';
import 'package:salesman_tracking_app/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<TFailure, List<User>>> getSalesman() async {
    try {
      final users = await remoteDataSource.getSalesman();

      return Right(users);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, String>> createSalesman({
    required String name,
    required String email,
    required String password,
    String? profileImage,
  }) async {
    try {
      final userId = await remoteDataSource.createSalesman(
        name: name,
        email: email,
        password: password,
        profileImage: profileImage,
      );

      return Right(userId);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, void>> deleteSalesman(String userId) async {
    try {
      await remoteDataSource.deleteSalesman(userId);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, void>> updateProfileImage({required String userId, required String imageUrl}) async {
    try {
      await remoteDataSource.updateProfileImage(userId: userId, imageUrl: imageUrl);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, void>> updateSalesman({
    required String userId,
    required String name,
    required String email,
    String? password,
    String? profileImage,
  }) async {
    try {
      await remoteDataSource.updateSalesman(
        userId: userId,
        name: name,
        email: email,
        password: password,
        profileImage: profileImage,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
