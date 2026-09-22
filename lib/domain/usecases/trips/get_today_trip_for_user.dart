import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../entities/trip.dart';
import '../../repositories/trip_repository.dart';

class GetTodayTripForUser {
  final TripRepository repository;

  GetTodayTripForUser(this.repository);

  Future<Either<TFailure, Trip?>> call(String userId) {
    return repository.getTodayTripForUser(userId);
  }
}
