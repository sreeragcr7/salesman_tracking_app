import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/core/constants/enums.dart';

import 'package:salesman_tracking_app/core/theme/app_colors.dart';
import 'package:salesman_tracking_app/core/widgets/app_app_bar.dart';
import 'package:salesman_tracking_app/domain/usecases/media/upload_profile_image.dart';
import 'package:salesman_tracking_app/domain/usecases/users/update_salesman.dart';
import 'package:salesman_tracking_app/init_dependencies.dart';

import '../../../domain/usecases/users/create_salesman.dart';
import '../../../domain/usecases/users/delete_salesman.dart';
import '../../../domain/usecases/users/get_salesmen.dart';
import '../../../domain/usecases/users/update_profile_image.dart';
import '../bloc/admin_bloc.dart';
import '../pages/create_salesman_page.dart';
import '../widgets/admin_dashboard_header.dart';
import '../widgets/salesman_list_section.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminBloc(
        getSalesmen: sl<GetSalesmen>(),
        createSalesman: sl<CreateSalesman>(),
        updateSalesman: sl<UpdateSalesman>(),
        deleteSalesman: sl<DeleteSalesman>(),
        uploadProfileImage: sl<UploadProfileImage>(),
        updateProfileImage: sl<UpdateProfileImage>(),
      )..add(
          const AdminSalesmanRequested(),
        ),
      child: const _AdminHomeView(),
    );
  }
}

class _AdminHomeView extends StatefulWidget {
  const _AdminHomeView();

  @override
  State<_AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<_AdminHomeView> {
  SalesmanFilter _selectedFilter = SalesmanFilter.all;

  int _totalSalesmen = 0;
  int _activeSalesmen = 0;
  int _completedSalesmen = 0;
  int _notStartedSalesmen = 0;

  void _openCreateSalesman(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<AdminBloc>(),
          child: const CreateSalesmanPage(),
        ),
      ),
    );
  }

  void _updateSummary({
    required int total,
    required int active,
    required int completed,
    required int notStarted,
  }) {
    if (!mounted) {
      return;
    }

    setState(() {
      _totalSalesmen = total;
      _activeSalesmen = active;
      _completedSalesmen = completed;
      _notStartedSalesmen = notStarted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: 'Salesman Tracking',
        showLogout: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminDashboardHeader(
              totalSalesmen: _totalSalesmen,
              activeSalesmen: _activeSalesmen,
              completedSalesmen: _completedSalesmen,
              notStartedSalesmen: _notStartedSalesmen,
              selectedFilter: _selectedFilter,
              onFilterSelected: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),

            const Divider(),

            const SizedBox(height: 5),

            Expanded(
              child: SalesmanListSection(
                selectedFilter: _selectedFilter,
                onSummaryUpdated: _updateSummary,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateSalesman(context),
        tooltip: 'Create Salesman',
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 3,
        child: const Icon(
          Icons.add,
          size: 28,
        ),
      ),
    );
  }
}
