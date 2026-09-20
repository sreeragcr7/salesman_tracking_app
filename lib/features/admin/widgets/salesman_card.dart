import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

class SalesmanCard extends StatelessWidget {
  final UserModel salesman;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const SalesmanCard({super.key, required this.salesman, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final hasProfileImage = salesman.profileImage != null && salesman.profileImage!.isNotEmpty;

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
        subtitle: Text(salesman.email),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
