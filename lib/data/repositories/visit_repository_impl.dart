import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../data/datasources/visit_remote_datasource.dart';
import '../../../domain/entities/visit.dart';
import '../../../domain/repositories/visit_repository.dart';

class VisitRepositoryImpl implements VisitRepository {
  final VisitRemoteDataSource remoteDataSource;

  VisitRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<TFailure, List<Visit>>> getVisitsForTrip(String tripId) async {
    try {
      final visits = await remoteDataSource.getVisitsForTrip(tripId);

      return Right(visits);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, Visit>> createVisit({
    required String tripId,
    required String shopName,
    String? description,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final visit = await remoteDataSource.createVisit(
        tripId: tripId,
        shopName: shopName,
        description: description,
        latitude: latitude,
        longitude: longitude,
      );

      return Right(visit);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
