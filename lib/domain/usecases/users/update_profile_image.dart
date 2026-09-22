import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/user_repository.dart';

class UpdateProfileImageParams {
  final String userId;
  final String imageUrl;

  const UpdateProfileImageParams({required this.userId, required this.imageUrl});
}

class UpdateProfileImage implements TUsecase<void, UpdateProfileImageParams> {
  final UserRepository repository;

  UpdateProfileImage(this.repository);

  @override
  Future<Either<TFailure, void>> call(UpdateProfileImageParams params) {
    return repository.updateProfileImage(userId: params.userId, imageUrl: params.imageUrl);
  }
}
