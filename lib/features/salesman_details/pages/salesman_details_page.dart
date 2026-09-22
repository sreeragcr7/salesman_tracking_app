import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:salesman_tracking_app/init_dependencies.dart';

import '../../../data/models/user_model.dart';
import '../../../domain/usecases/trips/get_working_trips.dart';
import '../bloc/salesman_details_bloc.dart';
import '../widgets/salesman_profile_header.dart';
import '../widgets/working_history_section.dart';

class SalesmanDetailsPage extends StatelessWidget {
  final UserModel salesman;

  const SalesmanDetailsPage({super.key, required this.salesman});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SalesmanDetailsBloc(getWorkingTrips: sl<GetWorkingTrips>())
            ..add(SalesmanWorkingDatesRequested(userId: salesman.uid)),
      child: _SalesmanDetailsView(salesman: salesman),
    );
  }
}

class _SalesmanDetailsView extends StatelessWidget {
  final UserModel salesman;

  const _SalesmanDetailsView({required this.salesman});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salesman Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SalesmanProfileHeader(salesman: salesman),
            const SizedBox(height: 32),
            const WorkingHistorySection(),
          ],
        ),
      ),
    );
  }
}
