import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Handles file uploads to Supabase Storage.
class StorageService {
  StorageService._();
  static final StorageService _instance = StorageService._();
  factory StorageService() => _instance;

  static final _storage = Supabase.instance.client.storage;

  static const String _kAvatarBucket = 'avatars';

  /// Uploads [imageFile] to the avatars bucket and returns the public URL.
  /// Throws a [StorageException] or [Exception] on failure.
  Future<String> uploadAvatar({
    required File imageFile,
    required String userId,
  }) async {
    final ext = imageFile.path.split('.').last.toLowerCase();
    final fileName = 'avatar_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    final bytes = await imageFile.readAsBytes();

    await _storage.from(_kAvatarBucket).uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentType(ext),
            upsert: true,
          ),
        );

    return _storage.from(_kAvatarBucket).getPublicUrl(fileName);
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
