import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/trip.dart';
import '../../repositories/trip_repository.dart';

class GetActiveTripForToday implements TUsecase<Trip?, NoParams> {
  final TripRepository repository;

  GetActiveTripForToday(this.repository);

  @override
  Future<Either<TFailure, Trip?>> call(NoParams params) {
    return repository.getActiveTripForToday();
  }
}
