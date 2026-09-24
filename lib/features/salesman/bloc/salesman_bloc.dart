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
import 'package:salesman_tracking_app/domain/usecases/trips/get_trip_locations.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/save_trip_location.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/start_day.dart';

part 'salesman_event.dart';
part 'salesman_state.dart';

class SalesmanBloc extends Bloc<SalesmanEvent, SalesmanState> {
  final StartDay startDay;
  final GetTodayTrip getTodayTrip;
  final SaveTripLocation saveTripLocation;
  final GetTripLocations getTripLocations;
  final FinishDay finishDay;

  final LocationService locationService;
  final LocationTrackingService trackingService;

  Position? _lastPosition;
  double _totalDistanceMeters = 0;

  bool _isSavingLocation = false;

  Position? _pendingLocation;
  String? _pendingTripId;

  SalesmanBloc({
    required this.startDay,
    required this.getTodayTrip,
    required this.saveTripLocation,
    required this.finishDay,
    required this.locationService,
    required this.trackingService,
    required this.getTripLocations,
  }) : super(const SalesmanDayInitial()) {
    on<SalesmanStartDayRequested>(_onStartDayRequested);
    on<SalesmanDayStatusRequested>(_onDayStatusRequested);
    on<SalesmanEndDayRequested>(_onEndDayRequested);
  }

  // ---------------------------------------------------------------------------
  // GPS VALIDATION
  // ---------------------------------------------------------------------------

  bool _isUsablePosition(Position position) {
    return position.accuracy > 0 && position.accuracy <= 40;
  }

  // ---------------------------------------------------------------------------
  // DISTANCE CALCULATION
  // ---------------------------------------------------------------------------

  bool _addValidDistance(Position previousPosition, Position currentPosition) {
    if (!_isUsablePosition(currentPosition)) {
      return false;
    }

    final segmentDistance = DistanceUtils.calculateDistanceInMeters(
      startLatitude: previousPosition.latitude,
      startLongitude: previousPosition.longitude,
      endLatitude: currentPosition.latitude,
      endLongitude: currentPosition.longitude,
    );

    // Ignore GPS noise / very small movements.
    if (segmentDistance < 8) {
      return false;
    }

    // Ignore unrealistic GPS jumps.
    if (segmentDistance > 300) {
      return false;
    }

    _totalDistanceMeters += segmentDistance;

    return true;
  }

  // ---------------------------------------------------------------------------
  // START DAY
  // ---------------------------------------------------------------------------

  Future<void> _onStartDayRequested(SalesmanStartDayRequested event, Emitter<SalesmanState> emit) async {
    try {
      emit(const SalesmanDayLoading());

      final position = await locationService.getCurrentPosition();

      if (!_isUsablePosition(position)) {
        emit(
          const SalesmanDayFailure(
            'Unable to get an accurate GPS location. '
            'Please move to an open area and try again.',
          ),
        );

        return;
      }

      _lastPosition = position;
      _totalDistanceMeters = 0;

      final startResult = await startDay(StartDayParams(latitude: position.latitude, longitude: position.longitude));

      await startResult.fold(
        (failure) async {
          emit(SalesmanDayFailure(failure.message));
        },
        (trip) async {
          // Save the starting GPS location.
          await _saveLocation(tripId: trip.id, position: position);

          // Start continuous GPS tracking.
          trackingService.start(
            onPosition: (position) {
              if (!_isUsablePosition(position)) {
                return;
              }

              final previousPosition = _lastPosition;

              if (previousPosition != null) {
                _addValidDistance(previousPosition, position);
              }

              _lastPosition = position;

              _saveLocation(tripId: trip.id, position: position);
            },
          );

          emit(SalesmanDayActive(trip as TripModel));
        },
      );
    } catch (e) {
      emit(SalesmanDayFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ---------------------------------------------------------------------------
  // SAVE GPS LOCATION
  // ---------------------------------------------------------------------------

  Future<void> _saveLocation({required String tripId, required Position position}) async {
    // If another location is currently being uploaded,
    // keep only the latest valid location.
    if (_isSavingLocation) {
      _pendingTripId = tripId;
      _pendingLocation = position;

      return;
    }

    _isSavingLocation = true;

    try {
      var currentTripId = tripId;
      var currentPosition = position;

      while (true) {
        final result = await saveTripLocation(
          SaveTripLocationParams(
            tripId: currentTripId,
            latitude: currentPosition.latitude,
            longitude: currentPosition.longitude,
            accuracy: currentPosition.accuracy,
          ),
        );

        result.fold((_) {
          // Location upload failure should not stop GPS tracking.
        }, (_) {});

        // Check whether a newer GPS position arrived
        // while the previous location was uploading.
        if (_pendingLocation == null || _pendingTripId == null) {
          break;
        }

        currentPosition = _pendingLocation!;
        currentTripId = _pendingTripId!;

        _pendingLocation = null;
        _pendingTripId = null;
      }
    } finally {
      _isSavingLocation = false;
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK TODAY'S TRIP
  // ---------------------------------------------------------------------------

  Future<void> _onDayStatusRequested(SalesmanDayStatusRequested event, Emitter<SalesmanState> emit) async {
    try {
      emit(const SalesmanDayLoading());

      final result = await getTodayTrip(const NoParams());

      if (result.isLeft()) {
        final failure = result.getLeft().toNullable();

        emit(SalesmanDayFailure(failure?.message ?? 'Failed to get today\'s trip.'));

        return;
      }

      final trip = result.getRight().toNullable();

      if (trip == null) {
        emit(const SalesmanDayInitial());

        return;
      }

      if (trip.status == 'completed') {
        emit(SalesmanDayCompleted(trip as TripModel));

        return;
      }

      final activeTrip = trip as TripModel;

      await _resumeTracking(activeTrip);

      emit(SalesmanDayActive(activeTrip));
    } catch (e) {
      emit(SalesmanDayFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ---------------------------------------------------------------------------
  // RESUME TRACKING
  // ---------------------------------------------------------------------------

  Future<void> _resumeTracking(TripModel trip) async {
    final locationsResult = await getTripLocations(trip.id);

    locationsResult.fold(
      (_) {
        // If previous locations cannot be loaded,
        // tracking will still resume from the current position.

        _lastPosition = null;

        _totalDistanceMeters = trip.totalDistance * 1000;
      },
      (locations) {
        // Continue from the distance already saved in the trip.
        _totalDistanceMeters = trip.totalDistance * 1000;

        if (locations.isNotEmpty) {
          final lastLocation = locations.last;

          _lastPosition = Position(
            latitude: lastLocation.latitude,
            longitude: lastLocation.longitude,
            timestamp: lastLocation.timestamp,
            accuracy: lastLocation.accuracy ?? 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        } else if (trip.startLatitude != null && trip.startLongitude != null) {
          _lastPosition = Position(
            latitude: trip.startLatitude!,
            longitude: trip.startLongitude!,
            timestamp: trip.startTime ?? DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
      },
    );

    trackingService.start(
      onPosition: (position) {
        if (!_isUsablePosition(position)) {
          return;
        }

        final previousPosition = _lastPosition;

        if (previousPosition != null) {
          _addValidDistance(previousPosition, position);
        }

        _lastPosition = position;

        _saveLocation(tripId: trip.id, position: position);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // END DAY
  // ---------------------------------------------------------------------------

  Future<void> _onEndDayRequested(SalesmanEndDayRequested event, Emitter<SalesmanState> emit) async {
    try {
      emit(const SalesmanDayEnding());

      // Stop continuous GPS tracking first.
      trackingService.stop();

      // Get the final GPS position.
      final position = await locationService.getCurrentPosition();

      final previousPosition = _lastPosition;

      // Add the final segment only when the GPS reading is reliable.
      if (previousPosition != null && _isUsablePosition(position)) {
        _addValidDistance(previousPosition, position);
      }

      // Only replace the last position when the final
      // GPS reading is usable.
      if (_isUsablePosition(position)) {
        _lastPosition = position;
      }

      // Save the final GPS position before completing the trip.
      await saveTripLocation(
        SaveTripLocationParams(
          tripId: event.tripId,
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        ),
      );

      // Convert meters to kilometers before sending
      // the value to Supabase.
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

  // ---------------------------------------------------------------------------
  // CLOSE
  // ---------------------------------------------------------------------------

  @override
  Future<void> close() {
    trackingService.dispose();

    return super.close();
  }
}
