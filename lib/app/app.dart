import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/core/loaders/app_loader.dart';
import 'package:salesman_tracking_app/domain/entities/user.dart';
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
        home: const AppEntry(),
      ),
    );
  }
}

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool? _onboardingCompleted;

  @override
  void initState() {
    super.initState();
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();

    final completed = prefs.getBool(OnboardingScreen.onboardingCompletedKey) ?? false;

    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingCompleted = completed;
    });
  }

  void _completeOnboarding() {
    if (!mounted) {
      return;
    }

    setState(() {
      _onboardingCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboardingCompleted = _onboardingCompleted;

    // We don't know the onboarding status yet.
    if (onboardingCompleted == null) {
      return const _AppLoadingScreen();
    }

    // First launch.
    if (!onboardingCompleted) {
      return OnboardingScreen(onGetStarted: _completeOnboarding);
    }

    // Onboarding completed.
    return const AuthGate();
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Only the initial session check should
        // display the full-screen loading screen.
        if (state is AuthInitial || state is AuthLoading) {
          return const _AppLoadingScreen();
        }

        if (state is AuthAuthenticated) {
          return _AuthenticatedEntry(user: state.user);
        }

        if (state is AuthUnauthenticated || state is AuthFailure) {
          return const LoginPage();
        }

        // Login loading must NOT come here.
        if (state is AuthLoginLoading) {
          return const LoginPage();
        }

        return const _AppLoadingScreen();
      },
    );
  }
}

class _AuthenticatedEntry extends StatelessWidget {
  const _AuthenticatedEntry({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    if (user.role == 'admin') {
      return const AdminHomePage();
    }

    if (user.role == 'salesman') {
      return const SalesmanHomePage();
    }

    return const LoginPage();
  }
}

class _AppLoadingScreen extends StatelessWidget {
  const _AppLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AppLoader());
  }
}
