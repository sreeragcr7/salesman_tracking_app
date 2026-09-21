part of 'salesman_details_bloc.dart';

sealed class SalesmanDetailsState extends Equatable {
  const SalesmanDetailsState();

  @override
  List<Object?> get props => [];
}

final class SalesmanDetailsInitial extends SalesmanDetailsState {
  const SalesmanDetailsInitial();
}

class SalesmanDetailsLoading extends SalesmanDetailsState {
  const SalesmanDetailsLoading();
}

class SalesmanDetailsLoaded extends SalesmanDetailsState {
  const SalesmanDetailsLoaded({required this.trips});

  final List<TripModel>trips;

  @override
  List<Object?> get props => [trips];
}

class SalesmanDetailsFailure extends SalesmanDetailsState {
  final String message;

  const SalesmanDetailsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
