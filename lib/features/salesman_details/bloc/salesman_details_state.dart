part of 'salesman_details_bloc.dart';

sealed class SalesmanDetailsState extends Equatable {
  const SalesmanDetailsState();

  @override
  List<Object?> get props => [];
}

final class SalesmanDetailsInitial extends SalesmanDetailsState {
  const SalesmanDetailsInitial();
}

final class SalesmanDetailsLoading extends SalesmanDetailsState {
  const SalesmanDetailsLoading();
}

final class SalesmanDetailsLoaded extends SalesmanDetailsState {
  const SalesmanDetailsLoaded({required this.trips, required this.todayTrip});

  final List<TripModel> trips;
  final Trip? todayTrip;

  @override
  List<Object?> get props => [trips, todayTrip];
}

final class SalesmanDetailsFailure extends SalesmanDetailsState {
  final String message;

  const SalesmanDetailsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
