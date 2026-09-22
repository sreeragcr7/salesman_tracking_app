import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/visit_model.dart';

abstract interface class VisitRemoteDataSource {
  Future<List<VisitModel>> getVisitsForTrip(String tripId);

  Future<VisitModel> createVisit({
    required String tripId,
    required String shopName,
    String? description,
    required double latitude,
    required double longitude,
  });
}

class VisitRemoteDataSourceImpl implements VisitRemoteDataSource {
  final SupabaseClient supabase;

  VisitRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<VisitModel>> getVisitsForTrip(String tripId) async {
    final response = await supabase.from('visits').select().eq('trip_id', tripId).order('visited_at', ascending: true);

    return (response as List).map((item) => VisitModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  @override
  Future<VisitModel> createVisit({
    required String tripId,
    required String shopName,
    String? description,
    required double latitude,
    required double longitude,
  }) async {
    final response = await supabase
        .from('visits')
        .insert({
          'trip_id': tripId,
          'shop_name': shopName,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
          'visited_at': DateTime.now().toUtc().toIso8601String(),
        })
        .select()
        .single();

    return VisitModel.fromJson(Map<String, dynamic>.from(response));
  }
}
