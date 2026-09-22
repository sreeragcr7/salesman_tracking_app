import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:salesman_tracking_app/core/theme/app_theme.dart';
import 'package:salesman_tracking_app/features/admin/pages/admin_home_page.dart';
import 'package:salesman_tracking_app/features/auth/bloc/auth_bloc.dart';
import 'package:salesman_tracking_app/features/auth/pages/login_page.dart';
import 'package:salesman_tracking_app/features/onboarding/pages/onboarding_page.dart';
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
        title: 'Salesman Tracking App',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const _AppEntry(),
      ),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    final completed = prefs.getBool(OnboardingScreen.onboardingCompletedKey) ?? false;

    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingCompleted = completed;
    });
  }

  void _openAuthGate() {
    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_onboardingCompleted == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!_onboardingCompleted!) {
      return OnboardingScreen(onGetStarted: _openAuthGate);
    }

    return const Scaffold(body: _AuthGate());
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AuthAuthenticated) {
          if (state.user.role == 'admin') {
            return const AdminHomePage();
          }

          return const SalesmanHomePage();
        }

        if (state is AuthUnauthenticated) {
          return const LoginPage();
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
