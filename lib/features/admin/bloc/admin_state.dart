part of 'admin_bloc.dart';

@immutable
sealed class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

final class AdminInitial extends AdminState {
  const AdminInitial();
}

final class AdminSalesmanLoading extends AdminState {
  const AdminSalesmanLoading();
}

final class AdminSalesmanLoaded extends AdminState {
  const AdminSalesmanLoaded(this.salesman);
  final List<UserModel> salesman;

  @override
  List<Object?> get props => [salesman];
}

class AdminSalesmanCreating extends AdminState {
  const AdminSalesmanCreating();
}

class AdminSalesmanCreated extends AdminState {
  const AdminSalesmanCreated();
}

class AdminSalesmenFailure extends AdminState {
  final String message;

  const AdminSalesmenFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminSalesmanCreateFailure extends AdminState {
  final String message;

  const AdminSalesmanCreateFailure(this.message);

  @override
  List<Object?> get props => [message];
}
