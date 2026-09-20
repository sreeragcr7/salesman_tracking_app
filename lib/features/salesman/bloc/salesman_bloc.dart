import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/core/services/location_service.dart';
import 'package:salesman_tracking_app/data/models/trip_model.dart';
import 'package:salesman_tracking_app/data/repositories/user_repository.dart';

part 'salesman_event.dart';
part 'salesman_state.dart';

class SalesmanBloc extends Bloc<SalesmanEvent, SalesmanState> {
  final UserRepository userRepository;
  final LocationService locationService;
  SalesmanBloc({required this.userRepository, required this.locationService}) : super(SalesmanDayInitial()) {
    on<SalesmanStartDayRequested>(_onStartDayRequested);
    on<SalesmanDayStatusRequested>(_onDayStatusRequested);
  }

  Future<void> _onStartDayRequested(SalesmanStartDayRequested event, Emitter<SalesmanState> emit) async {
    try {
      emit(const SalesmanDayLoading());

      final position = await locationService.getCurrentPosition();
      await userRepository.startDay(latitude: position.latitude, longitude: position.longitude);
      emit(const SalesmanDayStarted());
    } catch (e) {
      emit(SalesmanDayFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onDayStatusRequested(SalesmanDayStatusRequested event, Emitter<SalesmanState> emit) async {
    try {
      emit(SalesmanDayLoading());

      final trip = await userRepository.getActiveTripForToday();

      if (trip == null) {
        emit(const SalesmanDayInitial());
        return;
      }

      emit(SalesmanDayActive(trip));
    } catch (e) {
      emit(SalesmanDayFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
