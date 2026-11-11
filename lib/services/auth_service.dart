import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  SupabaseClient get _client => Supabase.instance.client;

  bool get isLoggedIn => _client.auth.currentSession != null;

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String role,
  }) {
    if (!const {'seeker', 'owner'}.contains(role)) {
      throw ArgumentError.value(role, 'role', 'Role registrasi tidak valid');
    }

    return _client.auth.signUp(
      email: email,
      password: password,
      data: {'role': role},
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() => _client.auth.signOut();
}
