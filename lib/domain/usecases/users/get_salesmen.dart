import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/user_repository.dart';

class GetSalesmen implements TUsecase<List<User>, NoParams> {
  final UserRepository repository;

  GetSalesmen(this.repository);

  @override
  Future<Either<TFailure, List<User>>> call(NoParams params) {
    return repository.getSalesman();
  }
}
