import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/trip.dart';
import '../../repositories/trip_repository.dart';

class GetWorkingTrips implements TUsecase<List<Trip>, String> {
  final TripRepository repository;

  GetWorkingTrips(this.repository);

  @override
  Future<Either<TFailure, List<Trip>>> call(String userId) {
    return repository.getWorkingTrips(userId);
  }
}
