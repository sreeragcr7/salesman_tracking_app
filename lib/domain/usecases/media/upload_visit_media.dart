import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/media_repository.dart';

class UploadVisitMediaParams {
  final String tripId;
  final File file;

  const UploadVisitMediaParams({required this.tripId, required this.file});
}

class UploadVisitMedia implements TUsecase<String, UploadVisitMediaParams> {
  final MediaRepository repository;

  UploadVisitMedia(this.repository);

  @override
  Future<Either<TFailure, String>> call(UploadVisitMediaParams params) {
    return repository.uploadVisitMedia(tripId: params.tripId, file: params.file);
  }
}
