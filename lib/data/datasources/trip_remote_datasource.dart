import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/trip_location_model.dart';
import '../models/trip_model.dart';

abstract interface class TripRemoteDataSource {
  Future<List<TripModel>> getWorkingTrips(String userId);

  Future<TripModel> startDay({required double latitude, required double longitude});

  Future<TripModel?> getActiveTripForToday();

  Future<TripModel?> getTodayTrip();

  Future<TripModel?> getTodayTripForUser(String userId);

  Future<TripModel> finishDay({
    required String tripId,
    required double latitude,
    required double longitude,
    required double totalDistance,
  });

  Future<void> saveTripLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    required double accuracy,
  });

  Future<List<TripLocationModel>> getTripLocations(String tripId);

  Future<TripModel> getTripById(String tripId);
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final SupabaseClient supabase;

  TripRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<TripModel>> getWorkingTrips(String userId) async {
    final response = await supabase.from('trips').select().eq('user_id', userId).order('date', ascending: false);

    return (response as List).map((item) => TripModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  @override
  Future<TripModel> startDay({required double latitude, required double longitude}) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final today = DateTime.now().toIso8601String().split('T').first;

    final existingTrip = await supabase
        .from('trips')
        .select('id, status')
        .eq('user_id', user.id)
        .eq('date', today)
        .limit(1);

    if (existingTrip.isNotEmpty) {
      final status = existingTrip.first['status'];

      if (status == 'completed') {
        throw Exception('Today\'s work day has already been completed.');
      }

      if (status == 'active') {
        throw Exception('Today\'s work day is already active.');
      }
    }

    final response = await supabase
        .from('trips')
        .insert({
          'user_id': user.id,
          'date': today,
          'start_time': DateTime.now().toUtc().toIso8601String(),
          'start_latitude': latitude,
          'start_longitude': longitude,
          'status': 'active',
        })
        .select()
        .single();

    return TripModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<TripModel?> getActiveTripForToday() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final today = DateTime.now().toIso8601String().split('T').first;

    final response = await supabase
        .from('trips')
        .select()
        .eq('user_id', user.id)
        .eq('date', today)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isEmpty) {
      return null;
    }

    return TripModel.fromJson(Map<String, dynamic>.from(response.first));
  }

  @override
  Future<TripModel?> getTodayTrip() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final today = DateTime.now().toIso8601String().split('T').first;

    final response = await supabase
        .from('trips')
        .select()
        .eq('user_id', user.id)
        .eq('date', today)
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isEmpty) {
      return null;
    }

    return TripModel.fromJson(Map<String, dynamic>.from(response.first));
  }

  @override
  Future<TripModel> finishDay({
    required String tripId,
    required double latitude,
    required double longitude,
    required double totalDistance,
  }) async {
    final response = await supabase
        .from('trips')
        .update({
          'end_time': DateTime.now().toUtc().toIso8601String(),
          'end_latitude': latitude,
          'end_longitude': longitude,
          'total_distance': totalDistance,
          'status': 'completed',
        })
        .eq('id', tripId)
        .select()
        .single();

    return TripModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<void> saveTripLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    await supabase.from('trip_locations').insert({
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<List<TripLocationModel>> getTripLocations(String tripId) async {
    final response = await supabase
        .from('trip_locations')
        .select()
        .eq('trip_id', tripId)
        .order('timestamp', ascending: true);

    return (response as List).map((item) => TripLocationModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  @override
  Future<TripModel> getTripById(String tripId) async {
    final response = await supabase.from('trips').select().eq('id', tripId).single();

    return TripModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<TripModel?> getTodayTripForUser(String userId) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    final response = await supabase
        .from('trips')
        .select()
        .eq('user_id', userId)
        .eq('date', today)
        .order('created_at', ascending: false)
        .limit(1);

    if (response.isEmpty) {
      return null;
    }

    return TripModel.fromJson(Map<String, dynamic>.from(response.first));
  }
}
