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
  const AdminShell({super.key});

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

  static int computeSelectedIndex(String location) {
    int best = 0;
    int bestLen = 0;
    for (int i = 0; i < _routes.length; i++) {
      if (location.startsWith(_routes[i]) && _routes[i].length > bestLen) {
        best = i;
        bestLen = _routes[i].length;
      }
    }
    return best;
  }

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  static final _editRegex = RegExp(r'^/admin/convocatorias/([^/]+)/edit$');
  static const _spinnerTimeout = Duration(seconds: 6);

  GoRouter? _router;
  String? _cachedLocation;
  bool _listening = false;
  bool _spinnerTimedOut = false;

  void _onRouterChange() {
    if (!mounted || _router == null) return;
    final newLocation = _router!.routerDelegate.currentConfiguration.uri.path;
    if (newLocation != _cachedLocation) {
      setState(() {
        _cachedLocation = newLocation;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_listening) {
      _router = GoRouter.of(context);
      _cachedLocation = _router!.routerDelegate.currentConfiguration.uri.path;
      _router!.routerDelegate.addListener(_onRouterChange);
      _listening = true;
    }
  }

  @override
  void dispose() {
    if (_listening && _router != null) {
      _router!.routerDelegate.removeListener(_onRouterChange);
    }
    super.dispose();
  }

  int _indexFor(String path) {
    if (path == '/admin' || path == '/admin/') return 0;
    if (path == '/admin/convocatorias') return 1;
    if (path == '/admin/users') return 2;
    if (path == '/admin/messages') return 3;
    if (path == '/admin/categories') return 4;
    return 0;
  }

  bool _isCreating(String path) => path == '/admin/convocatorias/new';

  String? _editingId(String path) {
    final m = _editRegex.firstMatch(path);
    return m?.group(1);
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

  @override
  Widget build(BuildContext context) {
    final location = _cachedLocation ?? GoRouterState.of(context).uri.path;
    final authState = ref.watch(authStateProvider);
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

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
    // Loading and refreshing both mean "the future is still in flight, wait
    // for it". AsyncRefreshing is the case on page reload where the previous
    // value (typically null from the pre-auth tick) is preserved while a
    // fresh fetch is running — we must not redirect on that stale value.
    if (profile.isLoading || profile.isRefreshing) {
      // Start a one-shot fallback timer the first time we see a spinner.
      // If after 6s the profile still hasn't resolved, give up and send
      // the user to /login so they're not stuck watching a spinner.
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
      // Terminal null — the profile genuinely doesn't exist. Send the user
      // to /login so they can re-authenticate rather than spinning forever.
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

    if (!location.startsWith('/admin')) {
      debugPrint(
        '[SHELL] location=$location is outside /admin — deferring to '
        'top-level route',
      );
      return const SizedBox.shrink();
    }

    final selectedIndex = AdminShell.computeSelectedIndex(location);
    final index = _indexFor(location);
    final creatingId = _isCreating(location);
    final editingId = _editingId(location);

    final Widget body;
    if (creatingId) {
      body = const EditConvocatoriaScreen();
    } else if (editingId != null) {
      body = EditConvocatoriaScreen(convocatoriaId: editingId);
    } else {
      body = IndexedStack(
        index: index,
        children: const [
          AdminDashboard(),
          ManageConvocatorias(),
          ManageUsers(),
          ManageMessages(),
          ManageCategories(),
        ],
      );
    }

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Admin'),
          actions: [
            IconButton(
              icon: const Icon(Icons.open_in_new),
              tooltip: lang == 'es' ? 'Ver sitio' : 'View site',
              onPressed: () {
                debugPrint('[SHELL] click Ver sitio (open_in_new) → /');
                context.go('/');
              },
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
                        onPressed: () => context.go('/'),
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
                onTap: () => context.go(AdminShell._routes[index]),
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
