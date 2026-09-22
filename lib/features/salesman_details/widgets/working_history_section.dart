import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/trip_model.dart';
import '../bloc/salesman_details_bloc.dart';
import 'working_date_tile.dart';

class WorkingHistorySection extends StatelessWidget {
  static const double allowancePerKm = 7.0;

  const WorkingHistorySection({super.key});

  double _calculateTotalDistance(List<TripModel> trips) {
    return trips.fold(0, (total, trip) => total + trip.totalDistance);
  }

  double _calculateTotalAllowance(List<TripModel> trips) {
    return _calculateTotalDistance(trips) * allowancePerKm;
  }

  bool _isSunday(TripModel trip) {
    return trip.date.weekday == DateTime.sunday;
  }

  bool _isMonthCompleted(DateTime date) {
    final now = DateTime.now();

    return date.year < now.year || (date.year == now.year && date.month < now.month);
  }

  List<List<TripModel>> _buildCompletedWeeks(List<TripModel> trips) {
    final workingTrips = trips.where((trip) => !_isSunday(trip)).toList();

    final completedWeeks = <List<TripModel>>[];

    for (var i = 0; i + 7 <= workingTrips.length; i += 7) {
      completedWeeks.add(workingTrips.sublist(i, i + 7));
    }

    return completedWeeks;
  }

  Map<String, List<TripModel>> _groupTripsByMonth(List<TripModel> trips) {
    final groupedTrips = <String, List<TripModel>>{};

    for (final trip in trips) {
      final key = DateFormat('yyyy-MM').format(trip.date);

      groupedTrips.putIfAbsent(key, () => []);
      groupedTrips[key]!.add(trip);
    }

    return groupedTrips;
  }

  Widget _buildTotalCard({required String title, required List<TripModel> trips}) {
    final totalDistance = _calculateTotalDistance(trips);
    final totalAllowance = _calculateTotalAllowance(trips);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SummaryValue(label: 'Distance', value: '${totalDistance.toStringAsFixed(1)} km'),
                ),
                Expanded(
                  child: _SummaryValue(
                    label: 'Allowance',
                    value: '₹${totalAllowance.toStringAsFixed(2)}',
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklySummary(List<TripModel> trips) {
    final completedWeeks = _buildCompletedWeeks(trips);

    if (completedWeeks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        ...completedWeeks.asMap().entries.map((entry) {
          final weekNumber = entry.key + 1;
          final weekTrips = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTotalCard(title: 'Week $weekNumber Total', trips: weekTrips),
          );
        }),
      ],
    );
  }

  Widget _buildMonthlySummary(List<TripModel> trips) {
    final groupedTrips = _groupTripsByMonth(trips);

    final completedMonths = groupedTrips.entries.where((entry) {
      return _isMonthCompleted(entry.value.first.date);
    }).toList();

    if (completedMonths.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text('Monthly Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...completedMonths.map((entry) {
          final monthTrips = entry.value;

          final monthName = DateFormat('MMMM yyyy').format(monthTrips.first.date);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTotalCard(title: '$monthName Total', trips: monthTrips),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Working History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        const Divider(),
        const SizedBox(height: 8),
        BlocBuilder<SalesmanDetailsBloc, SalesmanDetailsState>(
          builder: (context, state) {
            if (state is SalesmanDetailsLoading) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (state is SalesmanDetailsFailure) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(child: Text(state.message, textAlign: TextAlign.center)),
              );
            }

            if (state is SalesmanDetailsLoaded) {
              final trips = [...state.trips]..sort((a, b) => a.date.compareTo(b.date));

              if (trips.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text('No working history found.', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                );
              }

              return Column(
                children: [
                  ...trips.map(
                    (trip) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: WorkingDateTile(key: ValueKey(trip.id), trip: trip),
                    ),
                  ),

                  _buildWeeklySummary(trips),

                  _buildMonthlySummary(trips),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _SummaryValue({required this.label, required this.value, this.alignEnd = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
