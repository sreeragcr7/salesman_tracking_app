import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:salesman_tracking_app/data/models/trip_model.dart';
import 'package:salesman_tracking_app/domain/entities/trip.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/get_today_trip_for_user.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/get_working_trips.dart';

part 'salesman_details_event.dart';
part 'salesman_details_state.dart';

class SalesmanDetailsBloc extends Bloc<SalesmanDetailsEvent, SalesmanDetailsState> {
  final GetWorkingTrips getWorkingTrips;
  final GetTodayTripForUser getTodayTripForUser;

  SalesmanDetailsBloc({required this.getWorkingTrips, required this.getTodayTripForUser})
    : super(const SalesmanDetailsInitial()) {
    on<SalesmanWorkingDatesRequested>(_onWorkingDatesRequested);
  }

  Future<void> _onWorkingDatesRequested(SalesmanWorkingDatesRequested event, Emitter<SalesmanDetailsState> emit) async {
    try {
      emit(const SalesmanDetailsLoading());

      final workingTripsResult = await getWorkingTrips(event.userId);

      final todayTripResult = await getTodayTripForUser(event.userId);

      final workingTrips = workingTripsResult.fold((failure) {
        emit(SalesmanDetailsFailure(failure.message));

        return <Trip>[];
      }, (trips) => trips);

      if (state is SalesmanDetailsFailure) {
        return;
      }

      final todayTrip = todayTripResult.fold((failure) {
        emit(SalesmanDetailsFailure(failure.message));

        return null;
      }, (trip) => trip);

      if (state is SalesmanDetailsFailure) {
        return;
      }

      emit(SalesmanDetailsLoaded(trips: workingTrips.cast<TripModel>(), todayTrip: todayTrip));
    } catch (e) {
      emit(SalesmanDetailsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
