import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/core/services/location_tracking_service.dart';
import 'package:salesman_tracking_app/features/salesman/bloc/salesman_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../../core/services/location_service.dart';
import '../../../data/repositories/user_repository.dart';

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
  // bool _canStartDay() {
  //   final now = TimeOfDay.now();

  //   if (now.hour > 6) {
  //     return true;
  //   }

  //   if (now.hour == 6 && now.minute >= 30) {
  //     return true;
  //   }

  //   return false;
  // }
  bool _canStartDay() {
    return true;
  }

  void _showEndDayConfirmation(BuildContext context, String tripId) {
    showDialog(
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
                Navigator.of(dialogContext).pop();
              },
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                context.read<SalesmanBloc>().add(SalesmanEndDayRequested(tripId: tripId));
              },
              child: const Text('END DAY'),
            ),
          ],
        );
      },
    );
  }

  final String salesmanName;
  final String salesmanEmail;
  const _SalesmanHomeView({required this.salesmanName, required this.salesmanEmail});
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
              final canStartDay = _canStartDay();
              final activeTrip = state is SalesmanDayActive ? state.trip : null;
              final isEnding = state is SalesmanDayEnding;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Welcome, $salesmanName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(salesmanEmail, style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 32),
                  const Text('Today', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          dayCompleted
                              ? Icons.check_circle_outline
                              : dayStarted
                              ? Icons.location_on
                              : Icons.location_off_outlined,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dayCompleted
                              ? 'Day completed'
                              : dayStarted
                              ? 'Day started'
                              : 'Day not started',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dayCompleted
                              ? 'Your work day has ended for today.'
                              : dayStarted
                              ? 'Your work day has started.'
                              : 'Start your day to begin location tracking.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 20),
                        if (!dayStarted && !dayCompleted)
                          if (canStartDay)
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        context.read<SalesmanBloc>().add(const SalesmanStartDayRequested());
                                      },
                                icon: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.play_arrow_rounded),
                                label: Text(isLoading ? 'STARTING...' : 'START DAY'),
                              ),
                            )
                          else
                            const SizedBox(
                              width: double.infinity,
                              child: Text('Come back tomorrow to start your work day.', textAlign: TextAlign.center),
                            ),

                        if (dayStarted && activeTrip != null)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: GestureDetector(
                              onLongPress: isEnding
                                  ? null
                                  : () {
                                      _showEndDayConfirmation(context, activeTrip.id);
                                    },
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.red.shade300),
                                ),
                                child: Text(
                                  isEnding ? 'ENDING DAY...' : 'PRESS AND HOLD TO END DAY',
                                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade700),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
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
