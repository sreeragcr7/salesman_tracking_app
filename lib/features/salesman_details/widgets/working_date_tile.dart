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
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripVisitsPage(trip: trip)));
          },
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                _buildDateIcon(context),

                const SizedBox(width: 13),

                Expanded(child: _buildTripInfo(context)),

                const SizedBox(width: 12),

                _buildAllowance(context),

                const SizedBox(width: 8),

                Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateIcon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            DateFormat('dd').format(trip.date),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
          ),
          Text(
            DateFormat('MMM').format(trip.date).toUpperCase(),
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat('EEEE, yyyy').format(trip.date),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 7),

        Row(
          children: [
            Icon(Icons.route_outlined, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 5),
            Text(
              '${trip.totalDistance.toStringAsFixed(1)} km',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllowance(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '₹${allowance.toStringAsFixed(2)}',
          style: theme.textTheme.titleSmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 3),
        Text('Allowance', style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
