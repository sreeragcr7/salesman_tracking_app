part of 'salesman_bloc.dart';

@immutable
sealed class SalesmanState extends Equatable {
  const SalesmanState();

  @override
  List<Object?> get props => [];
}

class SalesmanDayInitial extends SalesmanState {
  const SalesmanDayInitial();
}

class SalesmanDayLoading extends SalesmanState {
  const SalesmanDayLoading();
}

class SalesmanDayStarted extends SalesmanState {
  const SalesmanDayStarted();
}

class SalesmanDayActive extends SalesmanState {
  const SalesmanDayActive(this.trip);
  final TripModel trip;

  @override
  List<Object?> get props => [trip];
}

class SalesmanDayEnding extends SalesmanState {
  const SalesmanDayEnding();
}

class SalesmanDayCompleted extends SalesmanState {
  final TripModel trip;

  const SalesmanDayCompleted(this.trip);

  @override
  List<Object?> get props => [trip];
}

class SalesmanDayFailure extends SalesmanState {
  const SalesmanDayFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
