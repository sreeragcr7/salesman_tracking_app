import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/domain/entities/trip.dart';
import 'package:salesman_tracking_app/domain/entities/trip_location.dart';

abstract interface class TripRepository {
  Future<Either<TFailure, List<Trip>>> getWorkingTrips(String userId);

  Future<Either<TFailure, Trip>> startDay({required double latitude, required double longitude});

  Future<Either<TFailure, Trip?>> getActiveTripForToday();

  Future<Either<TFailure, Trip?>> getTodayTrip();

  Future<Either<TFailure, Trip>> finishDay({
    required String tripId,
    required double latitude,
    required double longitude,
    required double totalDistance,
  });

  Future<Either<TFailure, void>> saveTripLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    required double accuracy,
  });

  Future<Either<TFailure, List<TripLocation>>> getTripLocations(String tripId);

  Future<Either<TFailure, Trip>> getTripById(String tripId);
}
