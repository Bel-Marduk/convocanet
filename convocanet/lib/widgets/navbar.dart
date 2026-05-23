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
  final void Function(String sectionId)? onNavigate;
  const Navbar({super.key, this.onNavigate});

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
            color: isDark
                ? const Color(0xFF0f172a).withOpacity(0.85)
                : theme.colorScheme.surface.withOpacity(0.8),
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withOpacity(0.2),
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 72,
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
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Icon(
                              Icons.campaign,
                              color: Colors.white,
                              size: 20.8,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF4f46e5), Color(0xFF06b6d4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: Text(
                              'ConvocaNet',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.8,
                                fontSize: 22.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (ResponsiveLayout.isDesktop(context)) ...[
                    const SizedBox(width: 60),
                    // Nav links
                    _NavLink(
                      label: lang == 'es' ? 'Inicio' : 'Home',
                      onTap: () => widget.onNavigate?.call('inicio'),
                      isDark: isDark,
                      theme: theme,
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Características' : 'Features',
                      onTap: () => widget.onNavigate?.call('caracteristicas'),
                      isDark: isDark,
                      theme: theme,
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Convocatorias' : 'Open Calls',
                      onTap: () => widget.onNavigate?.call('convocatorias'),
                      isDark: isDark,
                      theme: theme,
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Estadísticas' : 'Stats',
                      onTap: () => widget.onNavigate?.call('estadisticas'),
                      isDark: isDark,
                      theme: theme,
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Nosotros' : 'About',
                      onTap: () => widget.onNavigate?.call('nosotros'),
                      isDark: isDark,
                      theme: theme,
                    ),
                    _NavLink(
                      label: lang == 'es' ? 'Contacto' : 'Contact',
                      onTap: () => widget.onNavigate?.call('contacto'),
                      isDark: isDark,
                      theme: theme,
                    ),
                  ],

                  const Spacer(),

                  // Controls — always visible
                  const LanguageToggle(),
                  const SizedBox(width: 8),
                  const ThemeToggle(),

                  if (ResponsiveLayout.isDesktop(context)) ...[
                    // Auth buttons only on desktop
                    if (isAuthenticated) ...[
                      const SizedBox(width: 8),
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
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        child: Text(lang == 'es' ? 'Iniciar Sesión' : 'Sign In'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => context.go('/register'),
                        child: Text(lang == 'es' ? 'Registrarse' : 'Sign Up'),
                      ),
                    ],
                  ],

                  // Hamburger on mobile/tablet
                  if (!ResponsiveLayout.isDesktop(context)) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _showMobileMenu(context, lang, isAuthenticated);
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

  void _showMobileMenu(BuildContext context, String lang, bool isAuthenticated) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: Text(lang == 'es' ? 'Inicio' : 'Home'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate?.call('inicio');
                },
              ),
              ListTile(
                leading: const Icon(Icons.star),
                title: Text(lang == 'es' ? 'Características' : 'Features'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate?.call('caracteristicas');
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: Text(lang == 'es' ? 'Convocatorias' : 'Open Calls'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate?.call('convocatorias');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: Text(lang == 'es' ? 'Estadísticas' : 'Stats'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate?.call('estadisticas');
                },
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: Text(lang == 'es' ? 'Nosotros' : 'About'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate?.call('nosotros');
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_mail),
                title: Text(lang == 'es' ? 'Contacto' : 'Contact'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onNavigate?.call('contacto');
                },
              ),
              const Divider(),
              if (isAuthenticated) ...[
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/dashboard');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(lang == 'es' ? 'Perfil' : 'Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/profile');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text(lang == 'es' ? 'Cerrar sesión' : 'Sign out'),
                  onTap: () async {
                    Navigator.pop(context);
                    await AuthService.signOut();
                    if (context.mounted) context.go('/');
                  },
                ),
              ] else ...[
                ListTile(
                  leading: const Icon(Icons.login),
                  title: Text(lang == 'es' ? 'Iniciar Sesión' : 'Sign In'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/login');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_add),
                  title: Text(lang == 'es' ? 'Registrarse' : 'Sign Up'),
                  onTap: () {
                    Navigator.pop(context);
                    context.go('/register');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final ThemeData theme;

  const _NavLink({
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.theme,
  });

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _hovering
                  ? (widget.isDark
                      ? const Color(0xFF1e293b)
                      : const Color(0xFFf1f5f9))
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.label,
              style: widget.theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: widget.isDark
                    ? const Color(0xFFcbd5e1)
                    : const Color(0xFF475569),
                fontSize: 14.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
