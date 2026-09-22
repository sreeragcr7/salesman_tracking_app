import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/domain/entities/visit.dart';

abstract interface class VisitRepository {
  Future<Either<TFailure, List<Visit>>> getVisitsForTrip(String tripId);

  Future<Either<TFailure, Visit>> createVisit({
    required String tripId,
    required String shopName,
    String? description,
    required double latitude,
    required double longitude,
  });
}
