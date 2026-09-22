import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/core/services/location_service.dart';
import 'package:salesman_tracking_app/data/models/visit_model.dart';
import 'package:salesman_tracking_app/domain/usecases/media/create_visit_media.dart';
import 'package:salesman_tracking_app/domain/usecases/media/upload_visit_media.dart';
import 'package:salesman_tracking_app/domain/usecases/visits/create_visit.dart';

part 'visit_event.dart';
part 'visit_state.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final CreateVisit createVisit;
  final UploadVisitMedia uploadVisitMedia;
  final CreateVisitMedia createVisitMedia;

  final LocationService locationService;

  VisitBloc({
    required this.createVisit,
    required this.uploadVisitMedia,
    required this.createVisitMedia,
    required this.locationService,
  }) : super(const VisitInitial()) {
    on<VisitSubmissionRequested>(_onVisitSubmissionRequested);
  }

  Future<void> _onVisitSubmissionRequested(VisitSubmissionRequested event, Emitter<VisitState> emit) async {
    try {
      emit(const VisitSubmitting());

      final position = await locationService.getCurrentPosition();

      final visitResult = await createVisit(
        CreateVisitParams(
          tripId: event.tripId,
          shopName: event.shopName.trim(),
          description: event.description.trim().isEmpty ? null : event.description.trim(),
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );

      await visitResult.fold(
        (failure) async {
          emit(VisitFailure(failure.message));
        },
        (visit) async {
          for (final mediaFile in event.mediaFiles) {
            final mediaResult = await uploadVisitMedia(UploadVisitMediaParams(tripId: event.tripId, file: mediaFile));

            await mediaResult.fold(
              (failure) async {
                emit(VisitFailure(failure.message));
              },
              (mediaUrl) async {
                final extension = mediaFile.path.split('.').last.toLowerCase();

                final mediaType = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension) ? 'video' : 'image';

                final createMediaResult = await createVisitMedia(
                  CreateVisitMediaParams(visitId: visit.id, mediaUrl: mediaUrl, mediaType: mediaType),
                );

                createMediaResult.fold((failure) {
                  emit(VisitFailure(failure.message));
                }, (_) {});
              },
            );
          }

          emit(VisitSubmitted(visit as VisitModel));
        },
      );
    } catch (e) {
      emit(VisitFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
