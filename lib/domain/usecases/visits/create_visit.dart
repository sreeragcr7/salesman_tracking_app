import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/visit.dart';
import '../../repositories/visit_repository.dart';

class CreateVisitParams {
  final String tripId;
  final String shopName;
  final String? description;
  final double latitude;
  final double longitude;

  const CreateVisitParams({
    required this.tripId,
    required this.shopName,
    this.description,
    required this.latitude,
    required this.longitude,
  });
}

class CreateVisit implements TUsecase<Visit, CreateVisitParams> {
  final VisitRepository repository;

  CreateVisit(this.repository);

  @override
  Future<Either<TFailure, Visit>> call(CreateVisitParams params) {
    return repository.createVisit(
      tripId: params.tripId,
      shopName: params.shopName,
      description: params.description,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}
