import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/domain/entities/user.dart';

abstract interface class UserRepository {
  Future<Either<TFailure, List<User>>> getSalesman();

  Future<Either<TFailure, String>> createSalesman({
    required String name,
    required String email,
    required String password,
    String? profileImage,
  });

  Future<Either<TFailure, void>> deleteSalesman(String userId);

  Future<Either<TFailure, void>> updateProfileImage({required String userId, required String imageUrl});

  Future<Either<TFailure, void>> updateSalesman({
    required String userId,
    required String name,
    required String email,
    String? password,
    String? profileImage,
  });
}
