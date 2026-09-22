import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/trip_model.dart';
import '../../visits/pages/trip_visits_page.dart';

class WorkingDateTile extends StatelessWidget {
  static const double allowancePerKm = 7.0;

  final TripModel trip;

  const WorkingDateTile({super.key, required this.trip});

  double get allowance => trip.totalDistance * allowancePerKm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 22),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('MMMM d, yyyy').format(trip.date), style: textTheme.titleSmall),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.route_outlined,
                          size: 16,
                          color: textTheme.bodySmall?.color?.withValues(alpha: 0.60),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${trip.totalDistance.toStringAsFixed(1)} km',
                          style: textTheme.bodySmall?.copyWith(
                            color: textTheme.bodySmall?.color?.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${allowance.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Allowance',
                    style: textTheme.bodySmall?.copyWith(color: textTheme.bodySmall?.color?.withValues(alpha: 0.60)),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              Icon(Icons.chevron_right, color: textTheme.bodyMedium?.color?.withValues(alpha: 0.50)),
            ],
          ),
        ),
      ),
    );
  }
}
