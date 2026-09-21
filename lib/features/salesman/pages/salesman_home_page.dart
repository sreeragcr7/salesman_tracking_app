import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/location_service.dart';
import '../../../core/services/location_tracking_service.dart';
import '../../../data/repositories/user_repository.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/salesman_bloc.dart';
import '../widgets/end_day_confirmation_dialog.dart';
import '../widgets/salesman_header.dart';
import '../widgets/work_day_card.dart';

class SalesmanHomePage extends StatelessWidget {
  const SalesmanHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final salesman = authState.user;

    return BlocProvider(
      create: (_) => SalesmanBloc(
        userRepository: UserRepository(),
        locationService: LocationService(),
        trackingService: LocationTrackingService(),
      )..add(const SalesmanDayStatusRequested()),
      child: _SalesmanHomeView(salesmanName: salesman.name, salesmanEmail: salesman.email),
    );
  }
}

class _SalesmanHomeView extends StatelessWidget {
  final String salesmanName;
  final String salesmanEmail;

  const _SalesmanHomeView({required this.salesmanName, required this.salesmanEmail});

  bool _canStartDay() {
    // Temporarily enabled for testing.
    return true;
  }

  Future<void> _handleEndDay(BuildContext context, String tripId) async {
    final confirmed = await showEndDayConfirmationDialog(context);

    if (!confirmed || !context.mounted) {
      return;
    }

    context.read<SalesmanBloc>().add(SalesmanEndDayRequested(tripId: tripId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SalesmanBloc, SalesmanState>(
      listener: (context, state) {
        if (state is SalesmanDayStarted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Day started successfully.')));
        }

        if (state is SalesmanDayFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }

        if (state is SalesmanDayCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Work day ended successfully.')));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Salesman Dashboard'),
          actions: [
            IconButton(
              onPressed: () {
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocBuilder<SalesmanBloc, SalesmanState>(
            builder: (context, state) {
              final isLoading = state is SalesmanDayLoading;

              final dayStarted = state is SalesmanDayStarted || state is SalesmanDayActive;

              final dayCompleted = state is SalesmanDayCompleted;

              final activeTrip = state is SalesmanDayActive ? state.trip : null;

              final isEnding = state is SalesmanDayEnding;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SalesmanHeader(name: salesmanName, email: salesmanEmail),
                  WorkDayCard(
                    dayStarted: dayStarted,
                    dayCompleted: dayCompleted,
                    isLoading: isLoading,
                    canStartDay: _canStartDay(),
                    isEnding: isEnding,
                    activeTripId: activeTrip?.id,
                    onStartDay: () {
                      context.read<SalesmanBloc>().add(const SalesmanStartDayRequested());
                    },
                    onEndDay: () {
                      if (activeTrip != null) {
                        _handleEndDay(context, activeTrip.id);
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
