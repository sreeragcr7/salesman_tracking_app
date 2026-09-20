import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/data/models/user_model.dart';
import 'package:salesman_tracking_app/data/repositories/user_repository.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final UserRepository userRepository;
  AdminBloc({required this.userRepository}) : super(AdminInitial()) {
    on<AdminSalesmanRequested>(_onSalesmanRequested);
    on<AdminSalesmanCreateRequested>(_onSalesmanCreateRequested);
    on<AdminSalesmanDeleteRequested>(_onSalesmanDeleteRequested);
  }

  Future<void> _onSalesmanRequested(AdminSalesmanRequested event, Emitter<AdminState> emit) async {
    emit(const AdminSalesmanLoading());

    try {
      final salesman = await userRepository.getSalesman();
      emit(AdminSalesmanLoaded(salesman));
    } catch (e) {
      emit(const AdminSalesmenFailure('Unable to load salesmen.'));
    }
  }

  Future<void> _onSalesmanCreateRequested(AdminSalesmanCreateRequested event, Emitter<AdminState> emit) async {
    try {
      emit(const AdminSalesmanLoading());

      final userId = await userRepository.createSalesman(
        name: event.name,
        email: event.email,
        password: event.password,
      );

      if (event.profileImage != null) {
        final imageUrl = await userRepository.uploadProfileImage(userId: userId, file: File(event.profileImage!));

        await userRepository.updateProfileImage(userId: userId, imageUrl: imageUrl);
      }

      final salesmen = await userRepository.getSalesman();

      emit(AdminSalesmanLoaded(salesmen));
    } catch (e) {
      emit(AdminSalesmenFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onSalesmanDeleteRequested(AdminSalesmanDeleteRequested event, Emitter<AdminState> emit) async {
    try {
      emit(const AdminSalesmanLoading());

      await userRepository.deleteSalesman(event.userId);

      final salesman = await userRepository.getSalesman();
      emit(AdminSalesmanLoaded(salesman));
    } catch (e) {
      emit(AdminSalesmenFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
