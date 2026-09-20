import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository({SupabaseClient? supabase}) : _supabase = supabase ?? Supabase.instance.client;

  Future<UserModel> login({required String email, required String password}) async {
    final response = await _supabase.auth.signInWithPassword(email: email, password: password);

    final user = response.user;

    if (user == null) {
      throw Exception('Unable to login.');
    }

    final profile = await _supabase.from('profiles').select().eq('id', user.id).single();

    return UserModel.fromJson(user.id, profile);
  }

  Future<UserModel> getCurrentUserProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final profile = await _supabase.from('profiles').select().eq('id', user.id).single();

    return UserModel.fromJson(user.id, profile);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
