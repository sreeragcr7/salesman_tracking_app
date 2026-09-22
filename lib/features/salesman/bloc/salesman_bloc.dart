import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:salesman_tracking_app/core/services/location_service.dart';
import 'package:salesman_tracking_app/core/services/location_tracking_service.dart';
import 'package:salesman_tracking_app/core/usecase/usecase.dart';
import 'package:salesman_tracking_app/core/utils/distance_utils.dart';
import 'package:salesman_tracking_app/data/models/trip_model.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/finish_day.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/get_today_trip.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/save_trip_location.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/start_day.dart';

part 'salesman_event.dart';
part 'salesman_state.dart';

class SalesmanBloc extends Bloc<SalesmanEvent, SalesmanState> {
  final StartDay startDay;
  final GetTodayTrip getTodayTrip;
  final SaveTripLocation saveTripLocation;
  final FinishDay finishDay;

  final LocationService locationService;
  final LocationTrackingService trackingService;

  Position? _lastPosition;
  double _totalDistanceMeters = 0;

  SalesmanBloc({
    required this.startDay,
    required this.getTodayTrip,
    required this.saveTripLocation,
    required this.finishDay,
    required this.locationService,
    required this.trackingService,
  }) : super(const SalesmanDayInitial()) {
    on<SalesmanStartDayRequested>(_onStartDayRequested);
    on<SalesmanDayStatusRequested>(_onDayStatusRequested);
    on<SalesmanEndDayRequested>(_onEndDayRequested);
  }

  Future<void> _onStartDayRequested(SalesmanStartDayRequested event, Emitter<SalesmanState> emit) async {
    try {
      emit(const SalesmanDayLoading());

      final position = await locationService.getCurrentPosition();

      _lastPosition = position;
      _totalDistanceMeters = 0;

      final startResult = await startDay(StartDayParams(latitude: position.latitude, longitude: position.longitude));

      await startResult.fold(
        (failure) async {
          emit(SalesmanDayFailure(failure.message));
        },
        (trip) async {
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

              saveTripLocation(
                SaveTripLocationParams(
                  tripId: trip.id,
                  latitude: position.latitude,
                  longitude: position.longitude,
                  accuracy: position.accuracy,
                ),
              );
            },
          );

          emit(SalesmanDayActive(trip as TripModel));
        },
      );
    } catch (e) {
      emit(SalesmanDayFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDayStatusRequested(SalesmanDayStatusRequested event, Emitter<SalesmanState> emit) async {
    try {
      emit(const SalesmanDayLoading());

      final result = await getTodayTrip(const NoParams());

      result.fold(
        (failure) {
          emit(SalesmanDayFailure(failure.message));
        },
        (trip) {
          if (trip == null) {
            emit(const SalesmanDayInitial());
            return;
          }

          if (trip.status == 'completed') {
            emit(SalesmanDayCompleted(trip as TripModel));
            return;
          }

          emit(SalesmanDayActive(trip as TripModel));
        },
      );
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

      final finishResult = await finishDay(
        FinishDayParams(
          tripId: event.tripId,
          latitude: position.latitude,
          longitude: position.longitude,
          totalDistance: totalDistanceKm,
        ),
      );

      finishResult.fold(
        (failure) {
          emit(SalesmanDayFailure(failure.message));
        },
        (trip) {
          emit(SalesmanDayCompleted(trip as TripModel));
        },
      );
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
