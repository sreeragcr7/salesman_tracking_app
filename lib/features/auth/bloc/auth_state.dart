part of 'auth_bloc.dart';

@immutable
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

//initial
final class AuthInitial extends AuthState {
  const AuthInitial();
}

//loading
final class AuthLoading extends AuthState {
  const AuthLoading();
}

//authenticated
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserModel user;

  @override
  List<Object?> get props => [user];
}

// unauthenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

//Failure
class AuthFailure extends AuthState {
  const AuthFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
