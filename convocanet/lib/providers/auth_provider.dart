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

// Current profile provider (keepAlive so cached value survives navigation)
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  return await AuthService.getCurrentProfile();
}, keepAlive: true);

// Is authenticated provider
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// Is admin provider — holds last known value while profile re-fetches
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  final profile = ref.watch(currentProfileProvider);

  // User just logged out — reset
  if (user == null) return false;

  // Profile loaded — use its value
  if (profile.hasValue && !profile.isLoading) {
    return profile.value?.isAdmin ?? false;
  }

  // Profile is re-fetching (e.g. after token refresh) — use previous value
  // instead of returning false and triggering a redirect
  return ref.exists(isAdminCacheProvider)
      ? ref.read(isAdminCacheProvider)
      : false;
});

// Stores the last confirmed admin status for resilience during re-fetches
final isAdminCacheProvider = StateProvider<bool>((ref) {
  ref.listen(currentProfileProvider, (prev, next) {
    if (next.hasValue && !next.isLoading) {
      ref.controller.state = next.value?.isAdmin ?? false;
    }
  });
  return false;
});
