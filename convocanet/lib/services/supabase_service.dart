import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/constants.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    try {
      if (AppConstants.supabaseUrl.contains('YOUR_PROJECT')) {
        print('Warning: Supabase URL not configured.');
        return;
      }
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        anonKey: AppConstants.supabaseAnonKey,
      );
    } catch (e) {
      print('Error initializing Supabase: $e');
    }
  }

  // Auth
  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  // Realtime subscriptions
  static RealtimeChannel subscribeToTable(
    String table,
    void Function(PostgresChangesResponse) onData,
  ) {
    return client
        .channel('public:$table')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          callback: onData,
        )
        .subscribe();
  }
}
