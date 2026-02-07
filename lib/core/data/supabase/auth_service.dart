import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final _auth = Supabase.instance.client.auth;
  static Future<AuthResponse> signUp(String email, String password, {String? redirectTo}) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: redirectTo,
    );
    return res;
  }
  static Future<AuthResponse> signIn(String email, String password) async {
    final res = await _auth.signInWithPassword(email: email, password: password);
    return res;
  }

  static User? currentUser() => _auth.currentUser;

  static Future<void> signOut() async => await _auth.signOut();

  /// Listen to auth state changes. Returns the subscription so caller can cancel.
  static Stream<AuthState> onAuthStateChange() => _auth.onAuthStateChange;
}
