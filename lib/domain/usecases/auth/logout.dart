import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/core/usecase/usecase.dart';
import 'package:salesman_tracking_app/domain/repositories/auth_repository.dart';

class Logout implements TUsecase<void, NoParams> {
  final AuthRepository repository;

  Logout(this.repository);

  @override
  Future<Either<TFailure, void>> call(NoParams params) {
    return repository.logout();
  }
}
