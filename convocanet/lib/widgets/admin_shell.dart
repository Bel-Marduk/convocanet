import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/manage_convocatorias.dart';
import '../screens/admin/manage_users.dart';
import '../screens/admin/manage_messages.dart';
import '../screens/admin/manage_categories.dart';
import '../screens/admin/edit_convocatoria_screen.dart';

class AdminShell extends ConsumerStatefulWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  int _selectedIndex = 0;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSelectedIndex();
  }

  void _updateSelectedIndex() {
    final location = GoRouterState.of(context).uri.path;
    int best = 0;
    int bestLen = 0;
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i]) && _routes[i].length > bestLen) {
        best = i;
        bestLen = _routes[i].length;
      }
    }
    if (best != _selectedIndex) {
      setState(() => _selectedIndex = best);
    }
  }

  // Build child widget based on current route — bypasses ShellRoute child caching
  Widget _buildChild(String path) {
    if (path == '/admin/convocatorias/new') {
      return const EditConvocatoriaScreen();
    }
    if (path.startsWith('/admin/convocatorias/') && path.endsWith('/edit')) {
      final id = path.split('/')[3];
      return EditConvocatoriaScreen(convocatoriaId: id);
    }
    if (path == '/admin/convocatorias') return const ManageConvocatorias();
    if (path == '/admin/users') return const ManageUsers();
    if (path == '/admin/messages') return const ManageMessages();
    if (path == '/admin/categories') return const ManageCategories();
    return const AdminDashboard();
  }

  String _label(String lang, int index) {
    const labels = [
      ['Dashboard', 'Dashboard'],
      ['Convocatorias', 'Calls'],
      ['Usuarios', 'Users'],
      ['Mensajes', 'Messages'],
      ['Categorías', 'Categories'],
    ];
    return lang == 'es' ? labels[index][0] : labels[index][1];
  }

  void _onNavigate(int index) {
    setState(() => _selectedIndex = index);
    context.go(_routes[index]);
  }

  Future<void> _logout() async {
    final lang = ref.read(localeProvider).languageCode;
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
    if (confirmed == true && mounted) {
      await AuthService.signOut();
      if (mounted) context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    // Auth + role guard for all admin routes
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (authState.value == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/login');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final profile = ref.watch(currentProfileProvider);
    // Block until profile loads — prevents non-admin from flashing admin shell
    if (!profile.hasValue && !profile.hasError) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final isAdmin = ref.watch(isAdminProvider);
    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/dashboard');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Text(lang == 'es' ? 'Admin' : 'Admin'),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: lang == 'es' ? 'Ver sitio' : 'View site',
              onPressed: () => context.go('/'),
            ),
          ],
        ),
        drawer: Drawer(
          child: _buildNavContent(lang, theme, profile),
        ),
        body: widget.child,
      );
    }

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
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
            child: _buildNavContent(lang, theme, profile),
          ),
          // Main content
          Expanded(
            child: Column(
              children: [
                // Top bar
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
                        _label(lang, _selectedIndex),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.open_in_new),
                        tooltip: lang == 'es' ? 'Ver sitio' : 'View site',
                        onPressed: () => context.go('/'),
                      ),
                      const SizedBox(width: 8),
                      // Avatar + name
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
                // Page content — built directly from route to avoid ShellRoute caching
                Expanded(
                  child: _buildChild(GoRouterState.of(context).uri.path),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavContent(String lang, ThemeData theme, AsyncValue<dynamic> profile) {
    return SafeArea(
      child: Column(
        children: [
          // Logo / Header
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
          // Nav items
          ...List.generate(_routes.length, (index) {
            final selected = _selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: ListTile(
                leading: Icon(
                  selected ? _iconsSelected[index] : _icons[index],
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                title: Text(
                  _label(lang, index),
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
                onTap: () => _onNavigate(index),
              ),
            );
          }),
          const Spacer(),
          const Divider(height: 1),
          // Logout
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
              onTap: _logout,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
