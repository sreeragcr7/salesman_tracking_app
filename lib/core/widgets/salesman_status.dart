import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/domain/entities/trip.dart';

class SalesmanStatus {
  final String label;
  final Color color;

  const SalesmanStatus({required this.label, required this.color});

  factory SalesmanStatus.fromTrip(Trip? todayTrip) {
    if (todayTrip == null) {
      return const SalesmanStatus(label: 'Not Started', color: Colors.orange);
    }

    if (todayTrip.status == 'active') {
      return const SalesmanStatus(label: 'Active', color: Colors.green);
    }

    return const SalesmanStatus(label: 'Completed', color: Colors.grey);
  }
}
