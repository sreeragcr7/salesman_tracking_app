import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/media_repository.dart';

class UploadProfileImageParams {
  final String userId;
  final File file;

  const UploadProfileImageParams({required this.userId, required this.file});
}

class UploadProfileImage implements TUsecase<String, UploadProfileImageParams> {
  final MediaRepository repository;

  UploadProfileImage(this.repository);

  @override
  Future<Either<TFailure, String>> call(UploadProfileImageParams params) {
    return repository.uploadProfileImage(userId: params.userId, file: params.file);
  }
}
