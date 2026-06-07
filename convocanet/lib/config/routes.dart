import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../screens/landing/landing_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/user/dashboard_screen.dart';
import '../screens/user/favorites_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/user/convocatoria_detail_screen.dart';
import '../screens/user/convocatorias_browser_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_convocatorias.dart';
import '../screens/admin/manage_users.dart';
import '../screens/admin/manage_messages.dart';
import '../screens/admin/manage_categories.dart';
import '../screens/admin/edit_convocatoria_screen.dart';
import '../widgets/admin_shell.dart';
import '../screens/shared/not_found_screen.dart';
import '../providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Listen to both providers via a ChangeNotifier so GoRouter re-evaluates
  // redirects without recreating the entire router instance.
  final refreshNotifier = _AuthRefreshNotifier(ref);

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: refreshNotifier,
    errorBuilder: (context, state) {
      debugPrint(
        '[ERROR] errorBuilder called for path=${state.uri.path} '
        'matchedLocation=${state.matchedLocation}',
      );
      return const NotFoundScreen();
    },
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final path = state.matchedLocation;

      String? result;

      // Auth state still loading — allow navigation, screen guards will show spinner
      if (authState.isLoading) {
        result = null;
      } else {
        final isLoggedIn = authState.value?.session != null;
        final isProtected = path == '/dashboard' ||
            path == '/favorites' ||
            path == '/convocatorias' ||
            path == '/profile' ||
            path.startsWith('/admin');

        // Unauthenticated users on protected routes → login
        if (!isLoggedIn && isProtected) {
          result = '/login';
        } else if (isLoggedIn) {
          final user = ref.read(currentUserProvider);
          final profile = ref.read(currentProfileProvider);

          if (user != null &&
              !profile.hasError &&
              (profile.isLoading || profile.isRefreshing)) {
            debugPrint(
              '[REDIRECT] path=$path: waiting for profile '
              '(loading=${profile.isLoading}, refreshing=${profile.isRefreshing})',
            );
            result = null;
          } else if (profile.hasError) {
            debugPrint('[REDIRECT] path=$path: profile error → /login');
            result = '/login';
          } else if (profile.value != null) {
            final isAdmin = ref.read(isAdminProvider);
            debugPrint(
              '[REDIRECT] path=$path: profile resolved isAdmin=$isAdmin',
            );

            if (path == '/login' || path == '/register') {
              result = isAdmin ? '/admin' : '/dashboard';
            } else if (isAdmin && path == '/dashboard') {
              result = '/admin';
            } else if (path.startsWith('/admin') && !isAdmin) {
              result = '/dashboard';
            } else {
              result = null;
            }
          } else {
            debugPrint(
              '[REDIRECT] path=$path: profile null but not loading — waiting '
              'for provider to re-run (user=${user?.id})',
            );
            result = null;
          }
        } else {
          result = null;
        }
      }

      debugPrint('[REDIRECT] path=$path → result=$result');
      return result;
    },
    routes: [
      // Landing Page
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Convocatoria detail (public)
      GoRoute(
        path: '/convocatoria/:id',
        builder: (context, state) {
          debugPrint(
            '[ROUTE] /convocatoria/:id builder called id=${state.pathParameters['id']}',
          );
          return ConvocatoriaDetailScreen(
            convocatoriaId: state.pathParameters['id']!,
          );
        },
      ),

      // User routes (require auth)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/favorites',
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/convocatorias',
        builder: (context, state) => const ConvocatoriasBrowserScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Admin routes — single GoRoute catches the entire /admin tree.
      // AdminShell reads the current URL via a routerDelegate listener and
      // builds the correct sub-screen via an IndexedStack. This bypasses a
      // go_router 14.x limitation where GoRouterState.of(context).uri.path
      // doesn't trigger rebuilds when the URL changes within the same
      // wildcard GoRoute.
      GoRoute(
        path: '/admin',
        builder: (context, state) {
          debugPrint('[ROUTE] /admin builder called');
          return const AdminShell();
        },
      ),
      GoRoute(
        path: '/admin/:path(.*)',
        builder: (context, state) {
          debugPrint(
            '[ROUTE] /admin/:path(.*) builder called path=${state.pathParameters['path']}',
          );
          return const AdminShell();
        },
      ),
    ],
  );

  return router;
});

/// Notifies GoRouter to re-evaluate redirects when auth or profile changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (prev, next) {
      debugPrint(
        '[NOTIFIER] authState changed → redirect re-eval '
        '(hasSession=${next.value?.session != null})',
      );
      notifyListeners();
    });
    ref.listen(currentProfileProvider, (prev, next) {
      debugPrint(
        '[NOTIFIER] profile changed → redirect re-eval '
        '(loading=${next.isLoading}, refreshing=${next.isRefreshing}, '
        'hasValue=${next.hasValue}, hasError=${next.hasError})',
      );
      notifyListeners();
    });
  }

  @override
  void notifyListeners() {
    debugPrint('[NOTIFIER] notifyListeners() called');
    super.notifyListeners();
  }
}
