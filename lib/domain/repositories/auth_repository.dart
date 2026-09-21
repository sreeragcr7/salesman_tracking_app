import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/domain/entities/user.dart';

abstract interface class AuthRepository {
  Future<Either<TFailure, User>> login({required String email, required String password});

  Future<Either<TFailure, User?>> getCurrentUser();

  Future<Either<TFailure, void>> logout();
}
