import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/trip.dart';
import '../../repositories/trip_repository.dart';

class StartDayParams {
  final double latitude;
  final double longitude;

  const StartDayParams({required this.latitude, required this.longitude});
}

class StartDay implements TUsecase<Trip, StartDayParams> {
  final TripRepository repository;

  StartDay(this.repository);

  @override
  Future<Either<TFailure, Trip>> call(StartDayParams params) {
    return repository.startDay(latitude: params.latitude, longitude: params.longitude);
  }
}
