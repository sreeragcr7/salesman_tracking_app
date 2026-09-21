import 'package:flutter/material.dart';

class VisitMediaPickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const VisitMediaPickerButton({super.key, required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(onPressed: onPressed, icon: Icon(icon), label: Text(label)),
    );
  }
}
