import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/core/usecase/usecase.dart';
import 'package:salesman_tracking_app/data/models/user_model.dart';
import 'package:salesman_tracking_app/domain/usecases/media/upload_profile_image.dart';
import 'package:salesman_tracking_app/domain/usecases/users/create_salesman.dart';
import 'package:salesman_tracking_app/domain/usecases/users/delete_salesman.dart';
import 'package:salesman_tracking_app/domain/usecases/users/get_salesmen.dart';
import 'package:salesman_tracking_app/domain/usecases/users/update_profile_image.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetSalesmen getSalesmen;
  final CreateSalesman createSalesman;
  final DeleteSalesman deleteSalesman;
  final UploadProfileImage uploadProfileImage;
  final UpdateProfileImage updateProfileImage;

  AdminBloc({
    required this.getSalesmen,
    required this.createSalesman,
    required this.deleteSalesman,
    required this.uploadProfileImage,
    required this.updateProfileImage,
  }) : super(const AdminInitial()) {
    on<AdminSalesmanRequested>(_onSalesmanRequested);
    on<AdminSalesmanCreateRequested>(_onSalesmanCreateRequested);
    on<AdminSalesmanDeleteRequested>(_onSalesmanDeleteRequested);
  }

  Future<void> _onSalesmanRequested(AdminSalesmanRequested event, Emitter<AdminState> emit) async {
    emit(const AdminSalesmanLoading());

    final result = await getSalesmen(const NoParams());

    result.fold(
      (failure) {
        emit(AdminSalesmenFailure(failure.message));
      },
      (salesmen) {
        emit(AdminSalesmanLoaded(salesmen.cast<UserModel>()));
      },
    );
  }

  Future<void> _onSalesmanCreateRequested(AdminSalesmanCreateRequested event, Emitter<AdminState> emit) async {
    emit(const AdminSalesmanLoading());

    final createResult = await createSalesman(
      CreateSalesmanParams(name: event.name, email: event.email, password: event.password),
    );

    await createResult.fold(
      (failure) async {
        emit(AdminSalesmenFailure(failure.message));
      },
      (userId) async {
        if (event.profileImage != null) {
          final uploadResult = await uploadProfileImage(
            UploadProfileImageParams(userId: userId, file: File(event.profileImage!)),
          );

          final imageUrl = uploadResult.fold<String?>((failure) {
            emit(AdminSalesmenFailure(failure.message));
            return null;
          }, (url) => url);

          if (imageUrl == null) {
            return;
          }

          final updateResult = await updateProfileImage(UpdateProfileImageParams(userId: userId, imageUrl: imageUrl));

          final updateFailed = updateResult.fold((failure) {
            emit(AdminSalesmenFailure(failure.message));
            return true;
          }, (_) => false);

          if (updateFailed) {
            return;
          }
        }

        final salesmenResult = await getSalesmen(const NoParams());

        salesmenResult.fold(
          (failure) {
            emit(AdminSalesmenFailure(failure.message));
          },
          (salesmen) {
            emit(AdminSalesmanLoaded(salesmen.cast<UserModel>()));
          },
        );
      },
    );
  }

  Future<void> _onSalesmanDeleteRequested(AdminSalesmanDeleteRequested event, Emitter<AdminState> emit) async {
    emit(const AdminSalesmanLoading());

    final deleteResult = await deleteSalesman(event.userId);

    await deleteResult.fold(
      (failure) async {
        emit(AdminSalesmenFailure(failure.message));
      },
      (_) async {
        final salesmenResult = await getSalesmen(const NoParams());

        salesmenResult.fold(
          (failure) {
            emit(AdminSalesmenFailure(failure.message));
          },
          (salesmen) {
            emit(AdminSalesmanLoaded(salesmen.cast<UserModel>()));
          },
        );
      },
    );
  }
}
