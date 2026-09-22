

import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/data/datasources/trip_remote_datasource.dart';
import 'package:salesman_tracking_app/domain/entities/trip.dart';
import 'package:salesman_tracking_app/domain/entities/trip_location.dart';
import 'package:salesman_tracking_app/domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<TFailure, List<Trip>>> getWorkingTrips(String userId) async {
    try {
      final trips = await remoteDataSource.getWorkingTrips(userId);

      return Right(trips);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, Trip>> startDay({required double latitude, required double longitude}) async {
    try {
      final trip = await remoteDataSource.startDay(latitude: latitude, longitude: longitude);

      return Right(trip);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, Trip?>> getActiveTripForToday() async {
    try {
      final trip = await remoteDataSource.getActiveTripForToday();

      return Right(trip);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, Trip?>> getTodayTrip() async {
    try {
      final trip = await remoteDataSource.getTodayTrip();

      return Right(trip);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, Trip>> finishDay({
    required String tripId,
    required double latitude,
    required double longitude,
    required double totalDistance,
  }) async {
    try {
      final trip = await remoteDataSource.finishDay(
        tripId: tripId,
        latitude: latitude,
        longitude: longitude,
        totalDistance: totalDistance,
      );

      return Right(trip);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, void>> saveTripLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    try {
      await remoteDataSource.saveTripLocation(
        tripId: tripId,
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracy,
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, List<TripLocation>>> getTripLocations(String tripId) async {
    try {
      final locations = await remoteDataSource.getTripLocations(tripId);

      return Right(locations);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, Trip>> getTripById(String tripId) async {
    try {
      final trip = await remoteDataSource.getTripById(tripId);

      return Right(trip);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
