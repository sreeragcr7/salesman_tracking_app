import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/logout_confirmation_dialog.dart';
import '../../features/auth/bloc/auth_bloc.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showLogout;
  final bool logoutEnabled;

  const AppAppBar({super.key, required this.title, this.actions, this.showLogout = false, this.logoutEnabled = true});

  Future<void> _handleLogout(BuildContext context) async {
    final shouldLogout = await showLogoutConfirmationDialog(context);

    if (!shouldLogout || !context.mounted) {
      return;
    }

    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        ...?actions,
        if (showLogout)
          IconButton(
            onPressed: logoutEnabled ? () => _handleLogout(context) : null,
            icon: const Icon(Icons.logout),
            tooltip: logoutEnabled ? 'Logout' : 'Finish the work day before logging out',
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
