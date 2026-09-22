import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/visit_media.dart';
import '../../repositories/media_repository.dart';

class GetVisitMedia implements TUsecase<List<VisitMedia>, String> {
  final MediaRepository repository;

  GetVisitMedia(this.repository);

  @override
  Future<Either<TFailure, List<VisitMedia>>> call(String visitId) {
    return repository.getVisitMedia(visitId);
  }
}
