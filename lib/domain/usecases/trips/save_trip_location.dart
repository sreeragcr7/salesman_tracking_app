import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/trip_repository.dart';

class SaveTripLocationParams {
  final String tripId;
  final double latitude;
  final double longitude;
  final double accuracy;

  const SaveTripLocationParams({
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });
}

class SaveTripLocation implements TUsecase<void, SaveTripLocationParams> {
  final TripRepository repository;

  SaveTripLocation(this.repository);

  @override
  Future<Either<TFailure, void>> call(SaveTripLocationParams params) {
    return repository.saveTripLocation(
      tripId: params.tripId,
      latitude: params.latitude,
      longitude: params.longitude,
      accuracy: params.accuracy,
    );
  }
}
