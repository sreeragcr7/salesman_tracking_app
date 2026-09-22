import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/trip_model.dart';
import '../../visits/pages/trip_visits_page.dart';

class WorkingDateTile extends StatelessWidget {
  static const double allowancePerKm = 7.0;

  final TripModel trip;

  const WorkingDateTile({super.key, required this.trip});

  double get allowance => trip.totalDistance * allowancePerKm;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripVisitsPage(trip: trip)));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_today_outlined),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(trip.date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${trip.totalDistance.toStringAsFixed(1)} km',
                      style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${allowance.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
