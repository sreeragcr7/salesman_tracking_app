import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/trip_location.dart';
import '../../repositories/trip_repository.dart';

class GetTripLocations implements TUsecase<List<TripLocation>, String> {
  final TripRepository repository;

  GetTripLocations(this.repository);

  @override
  Future<Either<TFailure, List<TripLocation>>> call(String tripId) {
    return repository.getTripLocations(tripId);
  }
}
