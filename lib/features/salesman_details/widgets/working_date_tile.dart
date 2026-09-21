import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../data/models/trip_model.dart';
import '../../visits/pages/trip_visits_page.dart';

class WorkingDateTile extends StatelessWidget {
  final TripModel trip;

  const WorkingDateTile({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today_outlined),
      title: Text(DateFormat('dd MMMM yyyy').format(trip.date), style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripVisitsPage(trip: trip)));
      },
    );
  }
}
