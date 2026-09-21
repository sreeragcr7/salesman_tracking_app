import 'package:flutter/material.dart';

class VisitLocationNotice extends StatelessWidget {
  const VisitLocationNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
      child: const Row(
        children: [
          Icon(Icons.location_on_outlined),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your current location will be captured '
              'automatically when you submit this visit.',
            ),
          ),
        ],
      ),
    );
  }
}
