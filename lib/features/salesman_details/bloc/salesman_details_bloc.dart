import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/data/models/trip_model.dart';
import 'package:salesman_tracking_app/domain/usecases/trips/get_working_trips.dart';

part 'salesman_details_event.dart';
part 'salesman_details_state.dart';

class SalesmanDetailsBloc extends Bloc<SalesmanDetailsEvent, SalesmanDetailsState> {
  final GetWorkingTrips getWorkingTrips;

  SalesmanDetailsBloc({required this.getWorkingTrips}) : super(const SalesmanDetailsInitial()) {
    on<SalesmanWorkingDatesRequested>(_onWorkingDatesRequested);
  }

  Future<void> _onWorkingDatesRequested(SalesmanWorkingDatesRequested event, Emitter<SalesmanDetailsState> emit) async {
    try {
      emit(const SalesmanDetailsLoading());

      final result = await getWorkingTrips(event.userId);

      result.fold(
        (failure) {
          emit(SalesmanDetailsFailure(failure.message));
        },
        (trips) {
          emit(SalesmanDetailsLoaded(trips: trips.cast<TripModel>()));
        },
      );
    } catch (e) {
      emit(SalesmanDetailsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
