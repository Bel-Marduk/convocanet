import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/auth_service.dart';
import '../models/profile.dart';

// Auth state stream provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return SupabaseService.authStateChanges;
});

// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value?.session?.user;
});

// Current profile provider
//
// On a page reload, `authStateProvider` resolves with the session but the
// Supabase client's local RLS/session state can lag by a tick or two, causing
// the very first `profiles` query to return null (the postgrest request is
// made before the auth context is fully hydrated, so `auth.uid()` is null
// and the RLS policy returns zero rows). We retry a few times with a short
// delay so the common case of "session not yet propagated" resolves itself
// without the user seeing an empty profile. After 3 attempts we give up
// and let the caller treat the null as a real "profile not found".
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;

  for (var attempt = 0; attempt < 3; attempt++) {
    final profile = await AuthService.getCurrentProfile(user: user);
    if (profile != null) return profile;
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }
  return null;
});

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// Is admin provider
final isAdminProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile.value?.isAdmin ?? false;
});
