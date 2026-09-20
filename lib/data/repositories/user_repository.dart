import 'dart:io';

import 'package:salesman_tracking_app/data/models/trip_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class UserRepository {
  final SupabaseClient _supabase;

  UserRepository({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<List<UserModel>> getSalesman() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('role', 'salesman')
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => UserModel.fromJson(data['id'] as String, Map<String, dynamic>.from(data)))
        .toList();
  }

  Future<String> createSalesman({
    required String name,
    required String email,
    required String password,
    String? profileImage,
  }) async {
    final response = await _supabase.functions.invoke(
      'admin-users',
      body: {'action': 'create', 'name': name, 'email': email, 'password': password, 'profileImage': profileImage},
    );

    if (response.status != 200) {
      final data = response.data;

      if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }

      throw Exception('Unable to create salesman.');
    }

    final data = response.data;

    if (data is! Map || data['userId'] == null) {
      throw Exception('Salesman created, but user ID was not returned.');
    }

    return data['userId'].toString();
  }

  Future<List<DateTime>> getWorkingDates(String userId) async {
    final response = await _supabase.from('trips').select('date').eq('user_id', userId).order('date', ascending: false);

    final dates = <DateTime>{};
    for (final item in response as List) {
      final date = item['date'];

      if (date != null) {
        dates.add(DateTime.parse(date.toString()));
      }
    }
    return dates.toList();
  }

  Future<String> uploadProfileImage({required String userId, required File file}) async {
    final extension = file.path.split('.').last.toLowerCase();

    final storagePath = '$userId/profile.$extension';

    await _supabase.storage
        .from('profile-images')
        .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));

    return _supabase.storage.from('profile-images').getPublicUrl(storagePath);
  }

  Future<void> updateProfileImage({required String userId, required String imageUrl}) async {
    final response = await _supabase.functions.invoke(
      'admin-users',
      body: {'action': 'update', 'userId': userId, 'profileImage': imageUrl},
    );

    if (response.status != 200) {
      final data = response.data;

      if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }

      throw Exception('Unable to update profile image.');
    }
  }

  Future<TripModel> startDay({required double latitude, required double longitude}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final today = DateTime.now().toIso8601String().split('T').first;

    final existingTrip = await _supabase
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

    final response = await _supabase
        .from('trips')
        .insert({
          'user_id': user.id,
          'date': DateTime.now().toIso8601String().split('T').first,
          'start_time': DateTime.now().toUtc().toIso8601String(),
          'start_latitude': latitude,
          'start_longitude': longitude,
          'status': 'active',
        })
        .select()
        .single();

    return TripModel.fromJson(Map<String, dynamic>.from(response));
  }

  Future<TripModel?> getActiveTripForToday() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final today = DateTime.now().toIso8601String().split('T').first;

    final response = await _supabase
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

  Future<TripModel?> getTodayTrip() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final today = DateTime.now().toIso8601String().split('T').first;

    final response = await _supabase
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

  Future<TripModel> finishDay({
    required String tripId,
    required double latitude,
    required double longitude,
    required double totalDistance,
  }) async {
    final response = await _supabase
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

  Future<void> saveTripLocation({
    required String tripId,
    required double latitude,
    required double longitude,
    required double accuracy,
  }) async {
    await _supabase.from('trip_locations').insert({
      'trip_id': tripId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> deleteSalesman(String userId) async {
    final response = await _supabase.functions.invoke('admin-users', body: {'action': 'delete', 'userId': userId});

    if (response.status != 200) {
      final data = response.data;

      if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }
      throw Exception('Unable to delete salesman.');
    }
  }
}
