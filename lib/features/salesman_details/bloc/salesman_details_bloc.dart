import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/data/repositories/user_repository.dart';

part 'salesman_details_event.dart';
part 'salesman_details_state.dart';

class SalesmanDetailsBloc extends Bloc<SalesmanDetailsEvent, SalesmanDetailsState> {
  final UserRepository userRepository;

  SalesmanDetailsBloc({required this.userRepository}) : super(const SalesmanDetailsInitial()) {
    on<SalesmanWorkingDatesRequested>(_onWorkingDatesRequested);
  }

  Future<void> _onWorkingDatesRequested(SalesmanWorkingDatesRequested event, Emitter<SalesmanDetailsState> emit) async {
    try {
      emit(const SalesmanDetailsLoading());

      final dates = await userRepository.getWorkingDates(event.userId);

      emit(SalesmanDetailsLoaded(dates: dates));
    } catch (e) {
      emit(SalesmanDetailsFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
