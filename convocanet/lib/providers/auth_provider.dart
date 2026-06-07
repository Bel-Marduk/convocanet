import 'package:flutter/foundation.dart';
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
// Supabase client's local RLS/session state can lag by several hundred ms,
// causing the very first `profiles` query to return null (the postgrest
// request is made before the auth context is fully hydrated, so `auth.uid()`
// is null and the RLS policy returns zero rows). We retry with a backoff
// so the common case of "session not yet propagated" resolves itself without
// the user seeing an empty profile. After all attempts we give up and let
// the caller treat the null as a real "profile not found" (and the
// AdminShell / redirect then send the user to /login).
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    debugPrint('[PROFILE] currentProfileProvider: user is null, returning null');
    return null;
  }

  const maxAttempts = 5;
  const baseDelay = Duration(milliseconds: 400);

  for (var attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      final profile = await AuthService.getCurrentProfile(user: user);
      if (profile != null) {
        debugPrint(
          '[PROFILE] currentProfileProvider: loaded on attempt ${attempt + 1}, '
          'isAdmin=${profile.isAdmin}',
        );
        return profile;
      }
    } catch (e) {
      debugPrint(
        '[PROFILE] currentProfileProvider: attempt ${attempt + 1} threw: $e',
      );
    }
    if (attempt < maxAttempts - 1) {
      await Future<void>.delayed(baseDelay);
    }
  }
  debugPrint(
    '[PROFILE] currentProfileProvider: gave up after $maxAttempts attempts, '
    'returning null for ${user.id}',
  );
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
