import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/locale_provider.dart';
import '../../services/convocatoria_service.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _userCount = 0;
  int _activeCount = 0;
  double _totalAmount = 0;
  int _messageCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ConvocatoriaService.getStats();
      final messageRes = await Supabase.instance.client
          .from('contact_messages')
          .select('id');
      final messageCount = (messageRes as List).length;

      if (mounted) {
        setState(() {
          _userCount = stats['userCount'] as int? ?? 0;
          _activeCount = stats['activeCount'] as int? ?? 0;
          _totalAmount = stats['totalAmount'] as double? ?? 0;
          _messageCount = messageCount;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '\$${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '\$${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'es' ? 'Panel de Administración' : 'Admin Panel'),
      ),
      drawer: _AdminDrawer(lang: lang),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'es' ? 'Panel de Administración' : 'Admin Panel',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 32),

                // Stats cards
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    _AdminStatCard(
                      icon: Icons.people,
                      value: _loading ? '...' : _userCount.toString(),
                      label: lang == 'es' ? 'Usuarios' : 'Users',
                      color: theme.colorScheme.primary,
                      onTap: () => context.go('/admin/users'),
                    ),
                    _AdminStatCard(
                      icon: Icons.list,
                      value: _loading ? '...' : _activeCount.toString(),
                      label: lang == 'es' ? 'Activas' : 'Active',
                      color: const Color(0xFF10b981),
                      onTap: () => context.go('/admin/convocatorias'),
                    ),
                    _AdminStatCard(
                      icon: Icons.attach_money,
                      value: _loading ? '...' : _formatAmount(_totalAmount),
                      label: 'USD Total',
                      color: const Color(0xFFF59e0b),
                    ),
                    _AdminStatCard(
                      icon: Icons.email,
                      value: _loading ? '...' : _messageCount.toString(),
                      label: lang == 'es' ? 'Mensajes' : 'Messages',
                      color: const Color(0xFFEf4444),
                      onTap: () => context.go('/admin/messages'),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // Quick actions
                Text(
                  lang == 'es' ? 'Acciones Rápidas' : 'Quick Actions',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: Text(
                        lang == 'es' ? 'Nueva Convocatoria' : 'New Call',
                      ),
                      onPressed: () => context.go('/admin/convocatorias/new'),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.people),
                      label: Text(
                        lang == 'es' ? 'Gestionar Usuarios' : 'Manage Users',
                      ),
                      onPressed: () => context.go('/admin/users'),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.email),
                      label: Text(
                        lang == 'es' ? 'Ver Mensajes' : 'View Messages',
                      ),
                      onPressed: () => context.go('/admin/messages'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _AdminStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 250,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(icon, size: 32, color: color),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminDrawer extends StatelessWidget {
  final String lang;

  const _AdminDrawer({required this.lang});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  lang == 'es' ? 'Administración' : 'Admin',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(lang == 'es' ? 'Dashboard' : 'Dashboard'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin');
            },
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: Text(lang == 'es' ? 'Convocatorias' : 'Calls'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/convocatorias');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: Text(lang == 'es' ? 'Usuarios' : 'Users'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/users');
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(lang == 'es' ? 'Mensajes' : 'Messages'),
            onTap: () {
              Navigator.pop(context);
              context.go('/admin/messages');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.home),
            title: Text(lang == 'es' ? 'Ir al sitio' : 'Go to site'),
            onTap: () {
              Navigator.pop(context);
              context.go('/');
            },
          ),
        ],
      ),
    );
  }
}
