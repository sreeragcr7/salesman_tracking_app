import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:salesman_tracking_app/core/services/location_service.dart';
import 'package:salesman_tracking_app/core/services/location_tracking_service.dart';
import 'package:salesman_tracking_app/core/utils/distance_utils.dart';
import 'package:salesman_tracking_app/data/models/trip_model.dart';
import 'package:salesman_tracking_app/data/repositories/user_repository.dart';

part 'salesman_event.dart';
part 'salesman_state.dart';

class SalesmanBloc extends Bloc<SalesmanEvent, SalesmanState> {
  final UserRepository userRepository;
  final LocationService locationService;
  final LocationTrackingService trackingService;
  Position? _lastPosition;
  double _totalDistanceMeters = 0;
  SalesmanBloc({required this.userRepository, required this.locationService, required this.trackingService})
    : super(SalesmanDayInitial()) {
    on<SalesmanStartDayRequested>(_onStartDayRequested);
    on<SalesmanDayStatusRequested>(_onDayStatusRequested);
    on<SalesmanEndDayRequested>(_onEndDayRequested);
  }

  Future<void> _onStartDayRequested(SalesmanStartDayRequested event, Emitter<SalesmanState> emit) async {
    try {
      // final now = DateTime.now();

      // final startTime = DateTime(now.year, now.month, now.day, 12, 00);

      // if (now.isBefore(startTime)) {
      //   emit(const SalesmanDayFailure('Start Day is available from 6:30 AM.'));
      //   return;
      // }
      emit(const SalesmanDayLoading());

      final position = await locationService.getCurrentPosition();
      _lastPosition = position;
      _totalDistanceMeters = 0;
      final trip = await userRepository.startDay(latitude: position.latitude, longitude: position.longitude);

      trackingService.start(
        onPosition: (position) {
          final previousPosition = _lastPosition;

          if (previousPosition != null) {
            final segmentDistance = DistanceUtils.calculateDistanceInMeters(
              startLatitude: previousPosition.latitude,
              startLongitude: previousPosition.longitude,
              endLatitude: position.latitude,
              endLongitude: position.longitude,
            );

            _totalDistanceMeters += segmentDistance;
          }

          _lastPosition = position;

          userRepository.saveTripLocation(
            tripId: trip.id,
            latitude: position.latitude,
            longitude: position.longitude,
            accuracy: position.accuracy,
          );
        },
      );

      emit(SalesmanDayActive(trip));
    } catch (e) {
      emit(SalesmanDayFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDayStatusRequested(SalesmanDayStatusRequested event, Emitter<SalesmanState> emit) async {
    try {
      emit(SalesmanDayLoading());

      final trip = await userRepository.getTodayTrip();

      if (trip == null) {
        emit(const SalesmanDayInitial());
        return;
      }

      if (trip.status == 'completed') {
        emit(SalesmanDayCompleted(trip));
        return;
      }

      emit(SalesmanDayActive(trip));
    } catch (e) {
      emit(SalesmanDayFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onEndDayRequested(SalesmanEndDayRequested event, Emitter<SalesmanState> emit) async {
    try {
      emit(const SalesmanDayEnding());
      trackingService.stop();
      final position = await locationService.getCurrentPosition();

      final previousPosition = _lastPosition;

      if (previousPosition != null) {
        final finalSegmentDistance = DistanceUtils.calculateDistanceInMeters(
          startLatitude: previousPosition.latitude,
          startLongitude: previousPosition.longitude,
          endLatitude: position.latitude,
          endLongitude: position.longitude,
        );

        _totalDistanceMeters += finalSegmentDistance;
      }

      _lastPosition = position;

      final totalDistanceKm = _totalDistanceMeters / 1000;

      final completedTrip = await userRepository.finishDay(
        tripId: event.tripId,
        latitude: position.latitude,
        longitude: position.longitude,
        totalDistance: totalDistanceKm,
      );

      emit(SalesmanDayCompleted(completedTrip));
    } catch (e) {
      emit(SalesmanDayFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  @override
  Future<void> close() {
    trackingService.dispose();
    return super.close();
  }
}
