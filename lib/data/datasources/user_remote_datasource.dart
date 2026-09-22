import 'package:salesman_tracking_app/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class UserRemoteDataSource {
  Future<List<UserModel>> getSalesman();

  Future<String> createSalesman({
    required String name,
    required String email,
    required String password,
    String? profileImage,
  });

  Future<void> updateProfileImage({required String userId, required String imageUrl});

  Future<void> updateSalesman({
    required String userId,
    required String name,
    required String email,
    String? password,
    String? profileImage,
  });

  Future<void> deleteSalesman(String userId);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final SupabaseClient supabase;

  UserRemoteDataSourceImpl({required this.supabase});

  @override
  Future<List<UserModel>> getSalesman() async {
    final response = await supabase
        .from('profiles')
        .select()
        .eq('role', 'salesman')
        .order('created_at', ascending: false);

    return (response as List)
        .map((data) => UserModel.fromJson(data['id'] as String, Map<String, dynamic>.from(data)))
        .toList();
  }

  @override
  Future<String> createSalesman({
    required String name,
    required String email,
    required String password,
    String? profileImage,
  }) async {
    final response = await supabase.functions.invoke(
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

  @override
  Future<void> updateProfileImage({required String userId, required String imageUrl}) async {
    final response = await supabase.functions.invoke(
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

  @override
  Future<void> deleteSalesman(String userId) async {
    final response = await supabase.functions.invoke('admin-users', body: {'action': 'delete', 'userId': userId});

    if (response.status != 200) {
      final data = response.data;

      if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }

      throw Exception('Unable to delete salesman.');
    }
  }

  @override
  Future<void> updateSalesman({
    required String userId,
    required String name,
    required String email,
    String? password,
    String? profileImage,
  }) async {
    final body = <String, dynamic>{'action': 'update', 'userId': userId, 'name': name, 'email': email};

    if (password != null && password.isNotEmpty) {
      body['password'] = password;
    }

    if (profileImage != null && profileImage.isNotEmpty) {
      body['profileImage'] = profileImage;
    }

    final response = await supabase.functions.invoke('admin-users', body: body);

    if (response.status != 200) {
      final data = response.data;

      if (data is Map && data['error'] != null) {
        throw Exception(data['error']);
      }

      throw Exception('Unable to update salesman.');
    }
  }
}
