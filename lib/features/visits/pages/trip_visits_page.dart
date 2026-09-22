import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:salesman_tracking_app/domain/usecases/media/get_visit_media.dart';
import 'package:salesman_tracking_app/features/trip/pages/trip_route_page.dart';
import 'package:salesman_tracking_app/init_dependencies.dart';

import '../../../data/models/trip_model.dart';
import '../../../data/models/visit_media_model.dart';
import '../../../data/models/visit_model.dart';
import '../../../domain/usecases/visits/get_visits_for_trip.dart';
import '../../trip/widgets/trip_visit_card.dart';

class TripVisitsPage extends StatefulWidget {
  final TripModel trip;

  const TripVisitsPage({super.key, required this.trip});

  @override
  State<TripVisitsPage> createState() => _TripVisitsPageState();
}

class _TripVisitsPageState extends State<TripVisitsPage> {
  final GetVisitsForTrip _getVisitsForTrip = sl<GetVisitsForTrip>();
  final GetVisitMedia _getVisitMedia = sl<GetVisitMedia>();

  List<VisitModel> _visits = [];
  Map<String, List<VisitMediaModel>> _visitMedia = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVisits();
  }

  Future<void> _loadVisits() async {
    try {
      final visitsResult = await _getVisitsForTrip(widget.trip.id);

      await visitsResult.fold(
        (failure) async {
          if (!mounted) {
            return;
          }

          setState(() {
            _isLoading = false;
            _errorMessage = failure.message;
          });
        },
        (visits) async {
          final mediaMap = <String, List<VisitMediaModel>>{};

          for (final visit in visits) {
            final mediaResult = await _getVisitMedia(visit.id);

            mediaResult.fold(
              (failure) {
                mediaMap[visit.id] = [];
              },
              (media) {
                mediaMap[visit.id] = media.cast<VisitMediaModel>();
              },
            );
          }

          if (!mounted) {
            return;
          }

          setState(() {
            _visits = visits.cast<VisitModel>();
            _visitMedia = mediaMap;
            _isLoading = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _openRoute() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => TripRoutePage(tripId: widget.trip.id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat('dd MMMM yyyy').format(widget.trip.date)),
        actions: [
          IconButton(tooltip: 'View Route', icon: const Icon(Icons.location_on_rounded), onPressed: _openRoute),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_errorMessage!, textAlign: TextAlign.center),
        ),
      );
    }

    if (_visits.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No places were recorded for this day.',
            style: TextStyle(color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _visits.length,
      separatorBuilder: (_, _) {
        return const SizedBox(height: 12);
      },
      itemBuilder: (context, index) {
        final visit = _visits[index];

        return TripVisitCard(
          key: ValueKey(visit.id),
          visit: visit,
          visitNumber: index + 1,
          media: _visitMedia[visit.id] ?? [],
        );
      },
    );
  }
}
