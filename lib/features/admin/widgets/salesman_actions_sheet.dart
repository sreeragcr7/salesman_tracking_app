import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/features/admin/bloc/admin_bloc.dart';
import 'package:salesman_tracking_app/features/admin/pages/update_salesman_page.dart';

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

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<AdminBloc>(),
                      child: UpdateSalesmanPage(salesman: salesman),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
