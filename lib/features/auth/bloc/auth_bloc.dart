import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/core/usecase/usecase.dart';
import 'package:salesman_tracking_app/domain/entities/user.dart';
import 'package:salesman_tracking_app/domain/usecases/auth/get_current_user.dart';
import 'package:salesman_tracking_app/domain/usecases/auth/login.dart';
import 'package:salesman_tracking_app/domain/usecases/auth/logout.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Logout logout;
  final GetCurrentUser getCurrentUser;

  AuthBloc({required this.login, required this.logout, required this.getCurrentUser}) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthSessionRequested>(_onSessionRequested);
  }

  Future<void> _onSessionRequested(AuthSessionRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await getCurrentUser(const NoParams());

    result.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (user) {
        if (user == null) {
          emit(const AuthUnauthenticated());
          return;
        }

        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoginLoading());

    final result = await login(LoginParams(email: event.email, password: event.password));

    result.fold(
      (failure) {
        emit(AuthFailure(_getErrorMessage(failure.message)));
      },
      (user) {
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    final result = await logout(const NoParams());

    result.fold(
      (failure) {
        emit(AuthFailure(failure.message));
      },
      (_) {
        emit(const AuthUnauthenticated());
      },
    );
  }

  String _getErrorMessage(String error) {
    final message = error.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }

    if (message.contains('email not confirmed')) {
      return 'Please confirm your email before logging in.';
    }

    if (message.contains('network')) {
      return 'Please check your internet connection.';
    }

    return 'Unable to login. Please try again.';
  }
}
