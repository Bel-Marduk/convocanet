import 'package:flutter/material.dart';
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
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final path = state.matchedLocation;

      // Auth state still loading — don't redirect, screen guards will show spinner
      if (authState.isLoading) return null;

      final isLoggedIn = authState.value?.session != null;
      final isProtected = path == '/dashboard' ||
          path == '/favorites' ||
          path == '/convocatorias' ||
          path == '/profile' ||
          path.startsWith('/admin');

      // Unauthenticated users on protected routes → login
      if (!isLoggedIn && isProtected) return '/login';

      // Logged-in users on login/register → dashboard (skip for forgot-password)
      if (isLoggedIn &&
          (path == '/login' || path == '/register')) {
        final isAdmin = ref.read(isAdminProvider);
        return isAdmin ? '/admin' : '/dashboard';
      }

      // For authenticated users, wait for profile to load before admin checks
      if (isLoggedIn) {
        final profile = ref.read(currentProfileProvider);
        if (profile.isLoading || profile.hasError) {
          // Profile loading — block admin routes, allow user routes
          return path.startsWith('/admin') ? '/dashboard' : null;
        }

        final isAdmin = ref.read(isAdminProvider);

        // Admin users on /dashboard → admin
        if (path == '/dashboard' && isAdmin) return '/admin';

        // Non-admin users on admin routes → dashboard
        if (path.startsWith('/admin') && !isAdmin) return '/dashboard';
      }

      return null;
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
        builder: (context, state) => ConvocatoriaDetailScreen(
          convocatoriaId: state.pathParameters['id']!,
        ),
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

      // Admin routes (require admin role, wrapped in AdminShell)
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboard(),
          ),
          GoRoute(
            path: '/admin/convocatorias',
            builder: (context, state) => const ManageConvocatorias(),
          ),
          GoRoute(
            path: '/admin/convocatorias/new',
            builder: (context, state) => const EditConvocatoriaScreen(),
          ),
          GoRoute(
            path: '/admin/convocatorias/:id/edit',
            builder: (context, state) => EditConvocatoriaScreen(
              convocatoriaId: state.pathParameters['id'],
            ),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const ManageUsers(),
          ),
          GoRoute(
            path: '/admin/messages',
            builder: (context, state) => const ManageMessages(),
          ),
          GoRoute(
            path: '/admin/categories',
            builder: (context, state) => const ManageCategories(),
          ),
        ],
      ),
    ],
  );

  return router;
});

/// Notifies GoRouter to re-evaluate redirects when auth or profile changes.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (prev, next) {
      notifyListeners();
    });
    ref.listen(currentProfileProvider, (prev, next) {
      notifyListeners();
    });
  }
}
