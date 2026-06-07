import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _routes = [
    '/admin',
    '/admin/convocatorias',
    '/admin/users',
    '/admin/messages',
    '/admin/categories',
  ];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.list_alt_outlined,
    Icons.people_outline,
    Icons.email_outlined,
    Icons.category_outlined,
  ];

  static const _iconsSelected = [
    Icons.dashboard,
    Icons.list_alt,
    Icons.people,
    Icons.email,
    Icons.category,
  ];

  static String label(String lang, int index) {
    const labels = [
      ['Dashboard', 'Dashboard'],
      ['Convocatorias', 'Calls'],
      ['Usuarios', 'Users'],
      ['Mensajes', 'Messages'],
      ['Categorías', 'Categories'],
    ];
    return lang == 'es' ? labels[index][0] : labels[index][1];
  }

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  static const _spinnerTimeout = Duration(seconds: 6);

  bool _spinnerTimedOut = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[SHELL] initState branch=${widget.shell.currentIndex}');
  }

  @override
  void dispose() {
    debugPrint('[SHELL] dispose');
    super.dispose();
  }

  Future<void> _logout(BuildContext context, WidgetRef ref, String lang) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(lang == 'es' ? 'Cerrar sesión' : 'Sign out'),
        content: Text(lang == 'es'
            ? '¿Estás seguro de cerrar sesión?'
            : 'Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(lang == 'es' ? 'Cancelar' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(lang == 'es' ? 'Cerrar sesión' : 'Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await AuthService.signOut();
      if (context.mounted) context.go('/');
    }
  }

  void _goBranch(int index) {
    context.go(AdminShell._routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;
    final selectedIndex = widget.shell.currentIndex;

    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authState.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final profile = ref.watch(currentProfileProvider);
    if (profile.isLoading || profile.isRefreshing) {
      if (!_spinnerTimedOut) {
        _spinnerTimedOut = true;
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await Future<void>.delayed(_spinnerTimeout);
          if (!mounted) return;
          final p = ref.read(currentProfileProvider);
          if (p.isLoading || p.isRefreshing || p.value == null) {
            debugPrint(
              '[SHELL] spinner timeout (${_spinnerTimeout.inSeconds}s) — '
              'profile still not resolved, sending to /login',
            );
            if (context.mounted) context.go('/login');
          } else {
            _spinnerTimedOut = false;
          }
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    _spinnerTimedOut = false;
    if (profile.hasError) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (profile.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/dashboard');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final body = widget.shell;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(AdminShell.label(lang, selectedIndex)),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: lang == 'es' ? 'Ver sitio' : 'View site',
              onPressed: () => context.push('/'),
            ),
          ],
        ),
        drawer: Drawer(
          child: _buildNavContent(context, ref, lang, theme, profile, selectedIndex),
        ),
        body: body,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 220,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: theme.dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: _buildNavContent(context, ref, lang, theme, profile, selectedIndex),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(
                        color: theme.dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        AdminShell.label(lang, selectedIndex),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: lang == 'es' ? 'Ver sitio' : 'View site',
                        onPressed: () => context.push('/'),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primary,
                        child: Text(
                          (profile.value?.fullName.isNotEmpty == true)
                              ? profile.value!.fullName[0].toUpperCase()
                              : 'A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        profile.value?.fullName ?? '',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavContent(
    BuildContext context,
    WidgetRef ref,
    String lang,
    ThemeData theme,
    AsyncValue<dynamic> profile,
    int selectedIndex,
  ) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'ConvocaNet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ...List.generate(AdminShell._routes.length, (index) {
            final selected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: ListTile(
                leading: Icon(
                  selected ? AdminShell._iconsSelected[index] : AdminShell._icons[index],
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  AdminShell.label(lang, index),
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
                selected: selected,
                selectedTileColor: theme.colorScheme.primary.withOpacity(0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onTap: () => _goBranch(index),
              ),
            );
          }),
          const Spacer(),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: theme.colorScheme.error,
              ),
              title: Text(
                lang == 'es' ? 'Cerrar sesión' : 'Sign out',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () => _logout(context, ref, lang),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
