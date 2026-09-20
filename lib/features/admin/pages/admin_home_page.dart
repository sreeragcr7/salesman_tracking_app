import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/features/admin/pages/create_salesman_page.dart';

import '../../../data/repositories/user_repository.dart';
import '../bloc/admin_bloc.dart';

import '../widgets/salesman_card.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salesman Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

            const Text('Manage your sales team', style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 24),

            const Text('Salesmen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),

            const SizedBox(height: 12),

            Expanded(
              child: BlocBuilder<AdminBloc, AdminState>(
                builder: (context, state) {
                  if (state is AdminSalesmanLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is AdminSalesmenFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48),
                          const SizedBox(height: 12),
                          Text(state.message),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<AdminBloc>().add(const AdminSalesmanRequested());
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is AdminSalesmanLoaded) {
                    if (state.salesman.isEmpty) {
                      return const Center(child: Text('No salesmen found.'));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<AdminBloc>().add(const AdminSalesmanRequested());
                      },
                      child: ListView.builder(
                        itemCount: state.salesman.length,
                        itemBuilder: (context, index) {
                          final salesman = state.salesman[index];

                          return SalesmanCard(
                            salesman: salesman,
                            onTap: () {
                              // We'll add salesman details later.
                            },
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),

      // We'll connect this button to
      // Create Salesman later.
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(value: context.read<AdminBloc>(), child: const CreateSalesmanPage()),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
