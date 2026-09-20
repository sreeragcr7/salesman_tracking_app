import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../bloc/salesman_details_bloc.dart';

class SalesmanDetailsPage extends StatelessWidget {
  final UserModel salesman;

  const SalesmanDetailsPage({super.key, required this.salesman});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SalesmanDetailsBloc(userRepository: UserRepository())
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
    final hasProfileImage = salesman.profileImage != null && salesman.profileImage!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Salesman Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundImage: hasProfileImage ? NetworkImage(salesman.profileImage!) : null,
                  child: !hasProfileImage ? const Icon(Icons.person, size: 40) : null,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        salesman.name.isEmpty ? 'Unnamed Salesman' : salesman.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        salesman.email,
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(salesman.role, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            const Text('Working History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),

            const SizedBox(height: 10),

            const Divider(),

            const SizedBox(height: 8),

            BlocBuilder<SalesmanDetailsBloc, SalesmanDetailsState>(
              builder: (context, state) {
                if (state is SalesmanDetailsLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is SalesmanDetailsFailure) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(child: Text(state.message, textAlign: TextAlign.center)),
                  );
                }

                if (state is SalesmanDetailsLoaded) {
                  if (state.dates.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text('No working history found.', style: TextStyle(color: Colors.grey.shade600)),
                      ),
                    );
                  }

                  return Column(
                    children: state.dates.map((date) {
                      return _WorkingDateTile(date: date);
                    }).toList(),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkingDateTile extends StatelessWidget {
  final DateTime date;

  const _WorkingDateTile({required this.date});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.calendar_today_outlined),
      title: Text(DateFormat('dd MMMM yyyy').format(date), style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Daily trip details will be added next.
      },
    );
  }
}
