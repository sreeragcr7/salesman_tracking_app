import 'package:salesman_tracking_app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});

  Future<UserModel?> getCurrentUser();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl({required this.supabase});

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final response = await supabase.auth.signInWithPassword(email: email, password: password);

    final user = response.user;

    if (user == null) {
      throw Exception('Unable to login.');
    }

    final profile = await supabase.from('profiles').select().eq('id', user.id).single();

    return UserModel.fromJson(user.id, Map<String, dynamic>.from(profile));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final profile = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();

    if (profile == null) {
      return null;
    }

    return UserModel.fromJson(user.id, Map<String, dynamic>.from(profile));
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
