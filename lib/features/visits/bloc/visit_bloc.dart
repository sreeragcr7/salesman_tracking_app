import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/core/services/location_service.dart';
import 'package:salesman_tracking_app/data/models/visit_model.dart';
import 'package:salesman_tracking_app/data/repositories/user_repository.dart';

part 'visit_event.dart';
part 'visit_state.dart';

class VisitBloc extends Bloc<VisitEvent, VisitState> {
  final UserRepository userRepository;
  final LocationService locationService;
  VisitBloc({required this.userRepository, required this.locationService}) : super(VisitInitial()) {
    on<VisitSubmissionRequested>(_onVisitSubmissionRequested);
  }

  Future<void> _onVisitSubmissionRequested(VisitSubmissionRequested event, Emitter<VisitState> emit) async {
    try {
      emit(const VisitSubmitting());

      final position = await locationService.getCurrentPosition();

      final visit = await userRepository.createVisit(
        tripId: event.tripId,
        shopName: event.shopName.trim(),
        description: event.description.trim().isEmpty ? null : event.description.trim(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      for (final mediaFile in event.mediaFiles) {
        final mediaUrl = await userRepository.uploadVisitMedia(tripId: event.tripId, file: mediaFile);

        final extension = mediaFile.path.split('.').last.toLowerCase();

        final mediaType = ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(extension) ? 'video' : 'image';

        await userRepository.createVisitMedia(visitId: visit.id, mediaUrl: mediaUrl, mediaType: mediaType);
      }

      emit(VisitSubmitted(visit));
    } catch (e) {
      emit(VisitFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
