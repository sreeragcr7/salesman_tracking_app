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
