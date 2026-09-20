part of 'salesman_details_bloc.dart';

sealed class SalesmanDetailsEvent extends Equatable {
  const SalesmanDetailsEvent();

  @override
  List<Object?> get props => [];
}

class SalesmanWorkingDatesRequested extends SalesmanDetailsEvent {
  const SalesmanWorkingDatesRequested({required this.userId});
  final String userId;

  @override
  List<Object?> get props => [userId];
}
