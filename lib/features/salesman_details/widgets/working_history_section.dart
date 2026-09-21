import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/salesman_details_bloc.dart';
import 'working_date_tile.dart';

class WorkingHistorySection extends StatelessWidget {
  const WorkingHistorySection({super.key});

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
              if (state.trips.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text('No working history found.', style: TextStyle(color: Colors.grey.shade600)),
                  ),
                );
              }

              return Column(
                children: state.trips.map((trip) => WorkingDateTile(key: ValueKey(trip.id), trip: trip)).toList(),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}
