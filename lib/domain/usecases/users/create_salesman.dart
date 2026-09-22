import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/user_repository.dart';

class CreateSalesmanParams {
  final String name;
  final String email;
  final String password;
  final String? profileImage;

  const CreateSalesmanParams({required this.name, required this.email, required this.password, this.profileImage});
}

class CreateSalesman implements TUsecase<String, CreateSalesmanParams> {
  final UserRepository repository;

  CreateSalesman(this.repository);

  @override
  Future<Either<TFailure, String>> call(CreateSalesmanParams params) {
    return repository.createSalesman(
      name: params.name,
      email: params.email,
      password: params.password,
      profileImage: params.profileImage,
    );
  }
}
