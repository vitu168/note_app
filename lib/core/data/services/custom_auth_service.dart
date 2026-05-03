import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_app/core/services/api_service.dart';
import 'package:note_app/core/models/auth_response.dart';

class CustomAuthService {
  CustomAuthService._();

  static final ApiService _apiService = ApiService();
  static const String _tokenKey = 'auth_access_token';
  static const String _refreshTokenKey = 'auth_refresh_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _emailKey = 'auth_email';
  static const String _nameKey = 'auth_name';

  /// Sign up with email, password, and name
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/auth/signup',
        data: {
          'email': email,
          'password': password,
          'name': name,
        },
      );
      
      final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
      await _saveAuth(authResponse);
      _apiService.setAuthToken(authResponse.accessToken);
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
    String? fcmToken,
  }) async {
    try {
      final response = await _apiService.post(
        '/api/auth/signin',
        data: {
          'email': email,
          'password': password,
          if (fcmToken != null) 'fcmToken': fcmToken,
        },
      );
      
      final authResponse = AuthResponse.fromJson(response as Map<String, dynamic>);
      await _saveAuth(authResponse);
      _apiService.setAuthToken(authResponse.accessToken);
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Get current user from local storage
  static Future<AuthUser?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      final email = prefs.getString(_emailKey);
      final accessToken = prefs.getString(_tokenKey);

      if (userId == null || email == null || accessToken == null) {
        return null;
      }

      final name = prefs.getString(_nameKey);
      _apiService.setAuthToken(accessToken);

      return AuthUser(
        userId: userId,
        email: email,
        name: name,
        accessToken: accessToken,
      );
    } catch (e) {
      return null;
    }
  }

  /// Sign out and clear stored tokens
  static Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      if (userId != null && userId.isNotEmpty) {
        try {
          await _apiService.delete('/api/device/$userId');
        } catch (_) {}
      }

      // Invalidate the local FCM token (mobile only)
      if (!kIsWeb) {
        try {
          await FirebaseMessaging.instance.deleteToken();
        } catch (_) {}
      }

      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_emailKey);
      await prefs.remove(_nameKey);
      _apiService.removeAuthToken();
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Save auth response to local storage
  static Future<void> _saveAuth(AuthResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, response.accessToken);
      await prefs.setString(_refreshTokenKey, response.refreshToken);
      await prefs.setString(_userIdKey, response.userId);
      await prefs.setString(_emailKey, response.email);
      if (response.name != null) {
        await prefs.setString(_nameKey, response.name!);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get access token
  static Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (_) {
      return null;
    }
  }

  /// Send password reset email via backend
  static Future<void> forgotPassword({required String email}) async {
    await _apiService.post(
      '/api/auth/forgot-password',
      data: {'email': email},
    );
  }

  /// Save or refresh the FCM token for the current user device.
  /// Silently swallows errors — notifications are non-critical.
  static Future<void> saveFcmToken(String fcmToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      if (userId == null || userId.isEmpty) return;
      await _apiService.post(
        '/api/device/save-token',
        data: {'userId': userId, 'fcmToken': fcmToken},
      );
    } catch (_) {}
  }
}
