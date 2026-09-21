import 'package:flutter/material.dart';

class SalesmanHeader extends StatelessWidget {
  final String name;
  final String email;

  const SalesmanHeader({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome, $name', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(email, style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 32),
        const Text('Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 16),
      ],
    );
  }
}
