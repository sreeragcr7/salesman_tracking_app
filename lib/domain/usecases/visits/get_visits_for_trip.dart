import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/visit.dart';
import '../../repositories/visit_repository.dart';

class GetVisitsForTrip implements TUsecase<List<Visit>, String> {
  final VisitRepository repository;

  GetVisitsForTrip(this.repository);

  @override
  Future<Either<TFailure, List<Visit>>> call(String tripId) {
    return repository.getVisitsForTrip(tripId);
  }
}
