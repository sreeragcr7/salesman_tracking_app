import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/features/admin/widgets/delete_salesman_dialog.dart';
import 'package:salesman_tracking_app/features/admin/widgets/salesman_actions_sheet.dart';

import '../../salesman_details/pages/salesman_details_page.dart';
import '../bloc/admin_bloc.dart';
import 'salesman_card.dart';

class SalesmanListSection extends StatelessWidget {
  const SalesmanListSection({super.key});

  Future<void> _refresh(BuildContext context) async {
    context.read<AdminBloc>().add(const AdminSalesmanRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        if (state is AdminSalesmanLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AdminSalesmenFailure) {
          return _ErrorState(message: state.message, onRetry: () => _refresh(context));
        }

        if (state is AdminSalesmanLoaded) {
          if (state.salesman.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView.separated(
              itemCount: state.salesman.length,
              separatorBuilder: (_, _) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final salesman = state.salesman[index];

                return Dismissible(
                  key: ValueKey(salesman.uid),
                  direction: DismissDirection.startToEnd,
                  confirmDismiss: (_) {
                    return showDeleteSalesmanDialog(context, salesman.name);
                  },
                  onDismissed: (_) {
                    context.read<AdminBloc>().add(AdminSalesmanDeleteRequested(userId: salesman.uid));
                  },
                  background: const _DeleteBackground(),
                  child: SalesmanCard(
                    salesman: salesman,
                    onTap: () {
                      Navigator.of(
                        context,
                      ).push(MaterialPageRoute(builder: (_) => SalesmanDetailsPage(salesman: salesman)));
                    },
                    onLongPress: () {
                      showSalesmanActionsSheet(context, salesman);
                    },
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('No salesmen found.'));
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 24),
      decoration: BoxDecoration(color: Colors.red.shade700, borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.delete, color: Colors.white),
          SizedBox(width: 8),
          Text(
            'Delete',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
