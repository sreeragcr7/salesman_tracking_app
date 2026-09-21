import 'package:flutter/material.dart';

class AdminDashboardHeader extends StatelessWidget {
  const AdminDashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text('Manage your sales team', style: TextStyle(color: Colors.grey)),
        SizedBox(height: 24),
        Text('Salesmen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
