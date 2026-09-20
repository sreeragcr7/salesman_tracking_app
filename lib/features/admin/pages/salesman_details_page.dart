import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

class SalesmanDetailsPage extends StatelessWidget {
  final UserModel salesman;

  const SalesmanDetailsPage({super.key, required this.salesman});

  @override
  Widget build(BuildContext context) {
    final hasProfileImage = salesman.profileImage != null && salesman.profileImage!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Salesman Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            ),

            const SizedBox(height: 32),

            const Text('Working History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),

            const SizedBox(height: 10),

            const Divider(),

            const SizedBox(height: 12),

            Center(
              child: Text(
                'Working dates will appear here.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
