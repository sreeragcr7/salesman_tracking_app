import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/core/widgets/salesman_status.dart';

import '../../../data/models/user_model.dart';
import '../../../domain/entities/trip.dart';

class SalesmanProfileHeader extends StatelessWidget {
  final UserModel salesman;
  final Trip? todayTrip;

  const SalesmanProfileHeader({super.key, required this.salesman, required this.todayTrip});

  @override
  Widget build(BuildContext context) {
    final hasProfileImage = salesman.profileImage != null && salesman.profileImage!.isNotEmpty;

    final status = SalesmanStatus.fromTrip(todayTrip);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 42,
          backgroundImage: hasProfileImage ? NetworkImage(salesman.profileImage!) : null,
          child: !hasProfileImage ? const Icon(Icons.person, size: 40) : null,
        ),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                salesman.name.isEmpty ? 'Unnamed Salesman' : salesman.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                salesman.email,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 7),
                  Text(
                    status.label,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: status.color),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
