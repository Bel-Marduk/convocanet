import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/profile.dart';

class AuthService {
  static final _client = SupabaseService.client;

  // Sign up with email/password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? organization,
    String? phone,
    String? country,
    List<String> interests = const [],
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'https://bel-marduk.github.io/convocanet/',
      data: {
        'full_name': fullName,
        'organization': organization,
        'phone': phone,
        'country': country,
        'interests': interests,
      },
    );

    // Profile is auto-created by handle_new_user() trigger in Supabase.
    // Only upsert if the trigger hasn't created it yet (fallback).
    if (response.user != null) {
      try {
        await _client.from('profiles').upsert({
          'id': response.user!.id,
          'full_name': fullName,
          'organization': organization,
          'phone': phone,
          'country': country,
          'interests': interests,
          'role': 'user',
          'whatsapp_enabled': true,
        }).select().maybeSingle();
      } catch (e) {
        // Profile already created by trigger - ignore
        print('Profile upsert note: $e');
      }
    }

    return response;
  }

  // Sign in with email/password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign in with Google
  static Future<bool> signInWithGoogle() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  // Sign in with Apple
  static Future<bool> signInWithApple() async {
    return await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.flutter://login-callback/',
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'https://bel-marduk.github.io/convocanet/',
    );
  }

  // Get current user profile
  //
  // Pass [user] explicitly when calling from a Riverpod provider that
  // already watched `currentUserProvider`. Reading `_client.auth.currentUser`
  // directly has a race with the auth state stream: the stream can emit the
  // initial session before `currentUser` is populated, so a query fired
  // immediately after `authStateProvider` resolves may see a null user and
  // short-circuit to `return null`, leaving the caller permanently in a
  // null-profile loading state. Trusting the caller-supplied user avoids that.
  static Future<Profile?> getCurrentProfile({User? user}) async {
    final target = user ?? _client.auth.currentUser;
    if (target == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', target.id)
        .maybeSingle();

    if (response == null) return null;
    return Profile.fromJson(response);
  }

  // Update profile
  static Future<void> updateProfile(Profile profile) async {
    await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }
}
