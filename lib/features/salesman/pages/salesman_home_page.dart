import 'package:flutter/material.dart';

class SalesmanHomePage extends StatelessWidget {
  const SalesmanHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salesman Dashboard')),
      body: const Center(child: Text('Welcome Salesman', style: TextStyle(fontSize: 24))),
    );
  }
}
