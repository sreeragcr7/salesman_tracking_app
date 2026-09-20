import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

class SalesmanCard extends StatelessWidget {
  final UserModel salesman;
  final VoidCallback? onTap;

  const SalesmanCard({super.key, required this.salesman, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: salesman.profileImage != null && salesman.profileImage!.isNotEmpty
              ? NetworkImage(salesman.profileImage!)
              : null,
          child: salesman.profileImage == null || salesman.profileImage!.isEmpty ? const Icon(Icons.person) : null,
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
