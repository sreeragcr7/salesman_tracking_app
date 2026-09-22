import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../repositories/user_repository.dart';

class UpdateSalesman {
  final UserRepository repository;

  UpdateSalesman(this.repository);

  Future<Either<TFailure, void>> call(UpdateSalesmanParams params) {
    return repository.updateSalesman(
      userId: params.userId,
      name: params.name,
      email: params.email,
      password: params.password,
      profileImage: params.profileImage,
    );
  }
}

class UpdateSalesmanParams {
  final String userId;
  final String name;
  final String email;
  final String? password;
  final String? profileImage;

  const UpdateSalesmanParams({
    required this.userId,
    required this.name,
    required this.email,
    this.password,
    this.profileImage,
  });
}
