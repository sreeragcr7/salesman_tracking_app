import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/user_repository.dart';

class DeleteSalesman implements TUsecase<void, String> {
  final UserRepository repository;

  DeleteSalesman(this.repository);

  @override
  Future<Either<TFailure, void>> call(String userId) {
    return repository.deleteSalesman(userId);
  }
}
