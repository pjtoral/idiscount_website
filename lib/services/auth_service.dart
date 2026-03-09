import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) async {
    return await _supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: emailRedirectTo,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  bool isEmailVerified() {
    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  Future<bool> refreshAndCheckEmailVerified() async {
    try {
      final userResponse = await _supabase.auth.getUser();
      final freshUser = userResponse.user;
      if (freshUser != null) {
        return freshUser.emailConfirmedAt != null;
      }
    } catch (_) {}

    try {
      await _supabase.auth.refreshSession();
    } catch (_) {}

    final user = _supabase.auth.currentUser;
    return user?.emailConfirmedAt != null;
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  Future<void> resendVerificationEmail() async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not found or email is missing');
    }

    try {
      await _supabase.auth.resend(type: OtpType.signup, email: user.email!);
    } catch (e) {
      try {
        await _supabase.auth.resend(type: OtpType.recovery, email: user.email!);
      } catch (_) {
        rethrow;
      }
    }
  }
}
