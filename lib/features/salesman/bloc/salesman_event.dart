part of 'salesman_bloc.dart';

@immutable
sealed class SalesmanEvent extends Equatable {
  const SalesmanEvent();

  @override
  List<Object?> get props => [];
}

class SalesmanStartDayRequested extends SalesmanEvent {
  const SalesmanStartDayRequested();
}

class SalesmanDayStatusRequested extends SalesmanEvent {
  const SalesmanDayStatusRequested();
}

class SalesmanEndDayRequested extends SalesmanEvent {
  final String tripId;

  const SalesmanEndDayRequested({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}
