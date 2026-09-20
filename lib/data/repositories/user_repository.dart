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

  Future<void> createSalesman({
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
  }
}
