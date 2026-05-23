import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import 'theme_toggle.dart';
import 'language_toggle.dart';
import 'responsive_layout.dart';

class Navbar extends ConsumerStatefulWidget {
  const Navbar({super.key});

  @override
  ConsumerState<Navbar> createState() => _NavbarState();
}

class _NavbarState extends ConsumerState<Navbar> {
  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(isDark ? 0.7 : 0.8),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.2),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: SizedBox(
              height: 80,
              child: Row(
                children: [
                  // Logo
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => context.go('/'),
                      child: Row(
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF4f46e5), Color(0xFF06b6d4)],
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.campaign,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'ConvocaNet',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : theme.colorScheme.primary,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (ResponsiveLayout.isDesktop(context)) ...[
                    const SizedBox(width: 48),
                    // Nav links
                    _NavLink(
                      label: lang == 'es' ? 'Inicio' : 'Home',
                      onTap: () => context.go('/'),
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Características' : 'Features',
                      onTap: () => context.go('/#caracteristicas'),
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Convocatorias' : 'Open Calls',
                      onTap: () => context.go('/#convocatorias'),
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Estadísticas' : 'Stats',
                      onTap: () => context.go('/#estadisticas'),
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Nosotros' : 'About',
                      onTap: () => context.go('/#nosotros'),
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Contacto' : 'Contact',
                      onTap: () => context.go('/#contacto'),
                    ),
                  ],

                  const Spacer(),

                  // Controls
                  const LanguageToggle(),
                  const SizedBox(width: 12),
                  const ThemeToggle(),

                  if (isAuthenticated) ...[
                    const SizedBox(width: 12),
                    PopupMenuButton<String>(
                      icon: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Icon(
                          Icons.person,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      onSelected: (value) async {
                        switch (value) {
                          case 'dashboard':
                            context.go('/dashboard');
                            break;
                          case 'favorites':
                            context.go('/favorites');
                            break;
                          case 'profile':
                            context.go('/profile');
                            break;
                          case 'admin':
                            context.go('/admin');
                            break;
                          case 'logout':
                            await AuthService.signOut();
                            if (context.mounted) {
                              context.go('/');
                            }
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'dashboard',
                          child: Text(lang == 'es' ? 'Dashboard' : 'Dashboard'),
                        ),
                        PopupMenuItem(
                          value: 'favorites',
                          child: Text(lang == 'es' ? 'Favoritos' : 'Favorites'),
                        ),
                        PopupMenuItem(
                          value: 'profile',
                          child: Text(lang == 'es' ? 'Perfil' : 'Profile'),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'logout',
                          child: Text(lang == 'es' ? 'Cerrar sesión' : 'Sign out'),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(lang == 'es' ? 'Iniciar Sesión' : 'Sign In'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => context.go('/register'),
                      child: Text(lang == 'es' ? 'Registrarse' : 'Sign Up'),
                    ),
                  ],

                  if (ResponsiveLayout.isMobile(context)) ...[
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _showMobileMenu(context, lang);
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMobileMenu(BuildContext context, String lang) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(lang == 'es' ? 'Inicio' : 'Home'),
              onTap: () {
                Navigator.pop(context);
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: Text(lang == 'es' ? 'Convocatorias' : 'Open Calls'),
              onTap: () {
                Navigator.pop(context);
                context.go('/#convocatorias');
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(lang == 'es' ? 'Nosotros' : 'About'),
              onTap: () {
                Navigator.pop(context);
                context.go('/#nosotros');
              },
            ),
            ListTile(
              leading: const Icon(Icons.contact_mail),
              title: Text(lang == 'es' ? 'Contacto' : 'Contact'),
              onTap: () {
                Navigator.pop(context);
                context.go('/#contacto');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}
