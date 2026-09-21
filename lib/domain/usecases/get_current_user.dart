import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/core/usecase/usecase.dart';
import 'package:salesman_tracking_app/domain/entities/user.dart';
import 'package:salesman_tracking_app/domain/repositories/auth_repository.dart';

class GetCurrentUser implements TUsecase<User?, NoParams> {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  @override
  Future<Either<TFailure, User?>> call(NoParams params) {
    return repository.getCurrentUser();
  }
}
