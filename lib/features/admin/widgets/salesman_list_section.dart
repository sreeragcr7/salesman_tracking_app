import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/core/constants/enums.dart';
import 'package:salesman_tracking_app/data/models/user_model.dart';
import 'package:salesman_tracking_app/features/admin/widgets/delete_salesman_dialog.dart';
import 'package:salesman_tracking_app/features/admin/widgets/salesman_actions_sheet.dart';

import '../../../domain/entities/trip.dart';
import '../../../domain/usecases/trips/get_today_trip_for_user.dart';
import '../../../init_dependencies.dart';
import '../../salesman_details/pages/salesman_details_page.dart';
import '../bloc/admin_bloc.dart';
import 'salesman_card.dart';

class SalesmanListSection extends StatefulWidget {
  final SalesmanFilter selectedFilter;

  final void Function({required int total, required int active, required int completed, required int notStarted})
  onSummaryUpdated;

  const SalesmanListSection({super.key, required this.selectedFilter, required this.onSummaryUpdated});

  @override
  State<SalesmanListSection> createState() => _SalesmanListSectionState();
}

class _SalesmanListSectionState extends State<SalesmanListSection> {
  final Map<String, Trip?> _todayTrips = {};

  bool _tripsLoaded = false;

  Future<void> _refresh(BuildContext context) async {
    setState(() {
      _todayTrips.clear();
      _tripsLoaded = false;
    });

    context.read<AdminBloc>().add(const AdminSalesmanRequested());
  }

  Future<void> _loadTodayTrips(List<UserModel> salesmen) async {
    final getTodayTripForUser = sl<GetTodayTripForUser>();

    final results = await Future.wait(
      salesmen.map((salesman) async {
        final result = await getTodayTripForUser(salesman.uid);

        return MapEntry(salesman.uid, result.fold((failure) => null, (trip) => trip));
      }),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _todayTrips
        ..clear()
        ..addEntries(results);

      _tripsLoaded = true;
    });

    _updateSummary(salesmen);
  }

  void _updateSummary(List<UserModel> salesmen) {
    int active = 0;
    int completed = 0;
    int notStarted = 0;

    for (final salesman in salesmen) {
      final trip = _todayTrips[salesman.uid];

      if (trip == null) {
        notStarted++;
      } else if (trip.status == 'active') {
        active++;
      } else if (trip.status == 'completed') {
        completed++;
      }
    }

    widget.onSummaryUpdated(total: salesmen.length, active: active, completed: completed, notStarted: notStarted);
  }

  List<UserModel> _getFilteredSalesmen(List<UserModel> salesmen) {
    switch (widget.selectedFilter) {
      case SalesmanFilter.all:
        return salesmen;

      case SalesmanFilter.active:
        return salesmen.where((salesman) {
          return _todayTrips[salesman.uid]?.status == 'active';
        }).toList();

      case SalesmanFilter.completed:
        return salesmen.where((salesman) {
          return _todayTrips[salesman.uid]?.status == 'completed';
        }).toList();

      case SalesmanFilter.notStarted:
        return salesmen.where((salesman) {
          return _todayTrips[salesman.uid] == null;
        }).toList();
    }
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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) {
                return;
              }

              widget.onSummaryUpdated(total: 0, active: 0, completed: 0, notStarted: 0);
            });

            return const _EmptyState();
          }

          final salesmanIds = state.salesman.map((salesman) => salesman.uid).toSet();

          final loadedIds = _todayTrips.keys.toSet();

          if (!setEquals(salesmanIds, loadedIds)) {
            _loadTodayTrips(state.salesman);

            return const Center(child: CircularProgressIndicator());
          }

          if (!_tripsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final filteredSalesmen = _getFilteredSalesmen(state.salesman);

          if (filteredSalesmen.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 120), _NoFilteredSalesmen()],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refresh(context),
            child: ListView.separated(
              itemCount: filteredSalesmen.length,
              separatorBuilder: (_, _) {
                return const SizedBox(height: 12);
              },
              itemBuilder: (context, index) {
                final salesman = filteredSalesmen[index];

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
                    todayTrip: _todayTrips[salesman.uid],
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

class _NoFilteredSalesmen extends StatelessWidget {
  const _NoFilteredSalesmen();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Icon(Icons.people_outline, size: 48, color: textTheme.bodySmall?.color?.withValues(alpha: 0.50)),
        const SizedBox(height: 12),
        Text(
          'No salesmen in this category.',
          style: textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withValues(alpha: 0.65)),
        ),
      ],
    );
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
