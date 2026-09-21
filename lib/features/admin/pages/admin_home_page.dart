import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/user_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/admin_dashboard_header.dart';
import '../widgets/salesman_list_section.dart';
import '../pages/create_salesman_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AdminBloc(userRepository: UserRepository())..add(const AdminSalesmanRequested()),
      child: const _AdminHomeView(),
    );
  }
}

class _AdminHomeView extends StatelessWidget {
  const _AdminHomeView();

  void _openCreateSalesman(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(value: context.read<AdminBloc>(), child: const CreateSalesmanPage()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salesman Tracking'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdminDashboardHeader(),
            SizedBox(height: 24),
            Expanded(child: SalesmanListSection()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateSalesman(context),
        tooltip: 'Create Salesman',
        child: const Icon(Icons.add),
      ),
    );
  }
}
