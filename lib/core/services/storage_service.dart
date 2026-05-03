import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles file uploads to Supabase Storage.
class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;
  static final _storage = Supabase.instance.client.storage;
  static const String _kAvatarBucket = 'avatars';
  Future<String> uploadAvatar({
    required File imageFile,
    required String userId,
  }) async {
    try {
      final ext = imageFile.path.split('.').last.toLowerCase();
      final fileName =
          'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      final bytes = await imageFile.readAsBytes();

      await _storage.from(_kAvatarBucket).uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(
              contentType: _contentType(ext),
              upsert: true,
            ),
          );

      final publicUrl =
          _storage.from(_kAvatarBucket).getPublicUrl(fileName);
      debugPrint('[StorageService] Uploaded avatar: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('[StorageService] StorageException: ${e.message} | ${e.error}');
      throw Exception(e.message.isNotEmpty ? e.message : (e.error ?? 'Storage upload failed'));
    } catch (e) {
      debugPrint('[StorageService] Unexpected error: $e');
      rethrow;
    }
  }

  String _contentType(String ext) {
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}
