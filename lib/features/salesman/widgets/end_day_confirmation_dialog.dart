import 'package:flutter/material.dart';

Future<bool> showEndDayConfirmationDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('End work day?'),
        content: const Text(
          'Your location tracking will stop and '
          'today\'s trip will be completed.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('END DAY'),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
