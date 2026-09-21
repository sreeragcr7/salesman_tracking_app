import 'package:flutter/material.dart';

import '../../../data/models/user_model.dart';

void showSalesmanActionsSheet(BuildContext context, UserModel salesman) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Update Salesman'),
              onTap: () {
                Navigator.of(sheetContext).pop();

                // Update screen will be added next.
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
