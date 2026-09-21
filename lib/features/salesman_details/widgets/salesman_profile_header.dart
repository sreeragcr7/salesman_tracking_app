import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

class SalesmanProfileHeader extends StatelessWidget {
  final UserModel salesman;

  const SalesmanProfileHeader({super.key, required this.salesman});

  @override
  Widget build(BuildContext context) {
    final hasProfileImage = salesman.profileImage != null && salesman.profileImage!.isNotEmpty;

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
              const SizedBox(height: 6),
              Text(salesman.role, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ],
    );
  }
}
