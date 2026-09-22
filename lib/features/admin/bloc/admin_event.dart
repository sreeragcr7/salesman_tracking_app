part of 'admin_bloc.dart';

@immutable
sealed class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

// Admin wants to load the salesman list.
class AdminSalesmanRequested extends AdminEvent {
  const AdminSalesmanRequested();
}

final class AdminSalesmanCreateRequested extends AdminEvent {
  const AdminSalesmanCreateRequested({
    required this.name,
    required this.email,
    required this.password,
    this.profileImage,
  });
  final String name;
  final String email;
  final String password;
  final String? profileImage;

  @override
  List<Object?> get props => [name, email, password, profileImage];
}

final class AdminSalesmanDeleteRequested extends AdminEvent {
  const AdminSalesmanDeleteRequested({required this.userId});
  final String userId;

  @override
  List<Object?> get props => [userId];
}

final class AdminSalesmanUpdateRequested extends AdminEvent {
  final String userId;
  final String name;
  final String email;
  final String? password;
  final String? profileImage;

  const AdminSalesmanUpdateRequested({
    required this.userId,
    required this.name,
    required this.email,
    this.password,
    this.profileImage,
  });

  @override
  List<Object?> get props => [userId, name, email, password, profileImage];
}
