import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/visit_media_model.dart';

abstract interface class MediaRemoteDataSource {
  Future<String> uploadProfileImage({required String userId, required File file});

  Future<String> uploadVisitMedia({required String tripId, required File file});

  Future<VisitMediaModel> createVisitMedia({
    required String visitId,
    required String mediaUrl,
    required String mediaType,
  });

  Future<List<VisitMediaModel>> getVisitMedia(String visitId);
}

class MediaRemoteDataSourceImpl implements MediaRemoteDataSource {
  final SupabaseClient supabase;

  MediaRemoteDataSourceImpl({required this.supabase});

  @override
  Future<String> uploadProfileImage({required String userId, required File file}) async {
    final extension = file.path.split('.').last.toLowerCase();

    final storagePath = '$userId/profile.$extension';

    await supabase.storage
        .from('profile-images')
        .upload(storagePath, file, fileOptions: const FileOptions(upsert: true));

    return supabase.storage.from('profile-images').getPublicUrl(storagePath);
  }

  @override
  Future<String> uploadVisitMedia({required String tripId, required File file}) async {
    final extension = file.path.split('.').last.toLowerCase();

    final filePath = '$tripId/${DateTime.now().millisecondsSinceEpoch}.$extension';

    await supabase.storage.from('visit-media').upload(filePath, file);

    return supabase.storage.from('visit-media').getPublicUrl(filePath);
  }

  @override
  Future<VisitMediaModel> createVisitMedia({
    required String visitId,
    required String mediaUrl,
    required String mediaType,
  }) async {
    final response = await supabase
        .from('visit_media')
        .insert({'visit_id': visitId, 'media_url': mediaUrl, 'media_type': mediaType})
        .select()
        .single();

    return VisitMediaModel.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<List<VisitMediaModel>> getVisitMedia(String visitId) async {
    final response = await supabase
        .from('visit_media')
        .select()
        .eq('visit_id', visitId)
        .order('created_at', ascending: true);

    return (response as List).map((item) => VisitMediaModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }
}
