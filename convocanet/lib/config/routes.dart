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
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_convocatorias.dart';
import '../screens/admin/manage_users.dart';
import '../screens/admin/manage_messages.dart';
import '../screens/admin/edit_convocatoria_screen.dart';
import '../screens/shared/not_found_screen.dart';
import '../providers/auth_provider.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    errorBuilder: (context, state) => const NotFoundScreen(),
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
        redirect: (context, state) {
          if (authState.value == null) return '/login';
          return null;
        },
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/favorites',
        redirect: (context, state) {
          if (authState.value == null) return '/login';
          return null;
        },
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: '/profile',
        redirect: (context, state) {
          if (authState.value == null) return '/login';
          return null;
        },
        builder: (context, state) => const ProfileScreen(),
      ),

      // Admin routes (require admin role)
      GoRoute(
        path: '/admin',
        redirect: (context, state) {
          if (authState.value == null) return '/login';
          if (!ref.read(isAdminProvider)) return '/dashboard';
          return null;
        },
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: '/admin/convocatorias',
        redirect: (context, state) {
          if (authState.value == null) return '/login';
          if (!ref.read(isAdminProvider)) return '/dashboard';
          return null;
        },
        builder: (context, state) => const ManageConvocatorias(),
      ),
      GoRoute(
        path: '/admin/convocatorias/new',
        redirect: (context, state) {
          if (authState.value == null) return '/login';
          if (!ref.read(isAdminProvider)) return '/dashboard';
          return null;
        },
        builder: (context, state) => const EditConvocatoriaScreen(),
      ),
      GoRoute(
        path: '/admin/convocatorias/:id/edit',
        redirect: (context, state) {
          if (authState.value == null) return '/login';
          if (!ref.read(isAdminProvider)) return '/dashboard';
          return null;
        },
        builder: (context, state) => EditConvocatoriaScreen(
          convocatoriaId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/admin/users',
        redirect: (context, state) {
          if (authState.value == null) return '/login';
          if (!ref.read(isAdminProvider)) return '/dashboard';
          return null;
        },
        builder: (context, state) => const ManageUsers(),
      ),
      GoRoute(
        path: '/admin/messages',
        redirect: (context, state) {
          if (authState.value == null) return '/login';
          if (!ref.read(isAdminProvider)) return '/dashboard';
          return null;
        },
        builder: (context, state) => const ManageMessages(),
      ),
    ],
  );
});
