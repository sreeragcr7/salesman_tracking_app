import 'dart:io';

import 'package:fpdart/fpdart.dart';
import 'package:salesman_tracking_app/core/errors/failures.dart';
import 'package:salesman_tracking_app/domain/entities/visit_media.dart';

abstract interface class MediaRepository {
  Future<Either<TFailure, String>> uploadProfileImage({required String userId, required File file});

  Future<Either<TFailure, String>> uploadVisitMedia({required String tripId, required File file});

  Future<Either<TFailure, VisitMedia>> createVisitMedia({
    required String visitId,
    required String mediaUrl,
    required String mediaType,
  });

  Future<Either<TFailure, List<VisitMedia>>> getVisitMedia(String visitId);
}
