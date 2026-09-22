import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../core/errors/failures.dart';
import '../../../data/datasources/media_remote_datasource.dart';
import '../../../domain/entities/visit_media.dart';
import '../../../domain/repositories/media_repository.dart';

class MediaRepositoryImpl implements MediaRepository {
  final MediaRemoteDataSource remoteDataSource;

  MediaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<TFailure, String>> uploadProfileImage({required String userId, required File file}) async {
    try {
      final imageUrl = await remoteDataSource.uploadProfileImage(userId: userId, file: file);

      return Right(imageUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, String>> uploadVisitMedia({required String tripId, required File file}) async {
    try {
      final mediaUrl = await remoteDataSource.uploadVisitMedia(tripId: tripId, file: file);

      return Right(mediaUrl);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, VisitMedia>> createVisitMedia({
    required String visitId,
    required String mediaUrl,
    required String mediaType,
  }) async {
    try {
      final media = await remoteDataSource.createVisitMedia(visitId: visitId, mediaUrl: mediaUrl, mediaType: mediaType);

      return Right(media);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<Either<TFailure, List<VisitMedia>>> getVisitMedia(String visitId) async {
    try {
      final media = await remoteDataSource.getVisitMedia(visitId);

      return Right(media);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
