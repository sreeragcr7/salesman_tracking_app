import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/visit_media.dart';
import '../../repositories/media_repository.dart';

class CreateVisitMediaParams {
  final String visitId;
  final String mediaUrl;
  final String mediaType;

  const CreateVisitMediaParams({required this.visitId, required this.mediaUrl, required this.mediaType});
}

class CreateVisitMedia implements TUsecase<VisitMedia, CreateVisitMediaParams> {
  final MediaRepository repository;

  CreateVisitMedia(this.repository);

  @override
  Future<Either<TFailure, VisitMedia>> call(CreateVisitMediaParams params) {
    return repository.createVisitMedia(visitId: params.visitId, mediaUrl: params.mediaUrl, mediaType: params.mediaType);
  }
}
