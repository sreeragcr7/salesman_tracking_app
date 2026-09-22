import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/trip.dart';
import '../../repositories/trip_repository.dart';

class GetTripById implements TUsecase<Trip, String> {
  final TripRepository repository;

  GetTripById(this.repository);

  @override
  Future<Either<TFailure, Trip>> call(String tripId) {
    return repository.getTripById(tripId);
  }
}
