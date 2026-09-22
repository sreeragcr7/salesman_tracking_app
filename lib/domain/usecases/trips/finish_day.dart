import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/trip.dart';
import '../../repositories/trip_repository.dart';

class FinishDayParams {
  final String tripId;
  final double latitude;
  final double longitude;
  final double totalDistance;

  const FinishDayParams({
    required this.tripId,
    required this.latitude,
    required this.longitude,
    required this.totalDistance,
  });
}

class FinishDay implements TUsecase<Trip, FinishDayParams> {
  final TripRepository repository;

  FinishDay(this.repository);

  @override
  Future<Either<TFailure, Trip>> call(FinishDayParams params) {
    return repository.finishDay(
      tripId: params.tripId,
      latitude: params.latitude,
      longitude: params.longitude,
      totalDistance: params.totalDistance,
    );
  }
}
