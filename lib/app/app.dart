import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/features/admin/pages/admin_home_page.dart';
import 'package:salesman_tracking_app/features/auth/bloc/auth_bloc.dart';
import 'package:salesman_tracking_app/features/auth/pages/login_page.dart';
import 'package:salesman_tracking_app/features/salesman/pages/salesman_home_page.dart';
import 'package:salesman_tracking_app/init_dependencies.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(login: sl(), logout: sl(), getCurrentUser: sl())..add(const AuthSessionRequested()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Salesman-tracking-app',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
        home: const Scaffold(body: _AuthGate()),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.role == 'admin') {
            return const AdminHomePage();
          }

          return const SalesmanHomePage();
        }

        return const LoginPage();
      },
    );
  }
}
