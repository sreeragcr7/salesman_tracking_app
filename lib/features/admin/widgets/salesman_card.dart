import 'package:flutter/material.dart';
import 'package:salesman_tracking_app/core/widgets/salesman_status.dart';

import '../../../data/models/user_model.dart';
import '../../../domain/entities/trip.dart';

class SalesmanCard extends StatelessWidget {
  final UserModel salesman;
  final Trip? todayTrip;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SalesmanCard({super.key, required this.salesman, required this.todayTrip, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final hasProfileImage = salesman.profileImage != null && salesman.profileImage!.isNotEmpty;

    final status = SalesmanStatus.fromTrip(todayTrip);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: hasProfileImage ? NetworkImage(salesman.profileImage!) : null,
          child: !hasProfileImage ? const Icon(Icons.person) : null,
        ),
        title: Text(
          salesman.name.isEmpty ? 'Unnamed Salesman' : salesman.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(salesman.email),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  status.label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: status.color),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
