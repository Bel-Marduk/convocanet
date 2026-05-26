import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/locale_provider.dart';
import '../../services/convocatoria_service.dart';

class AdminDashboard extends ConsumerStatefulWidget {
  const AdminDashboard({super.key});

  @override
  ConsumerState<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends ConsumerState<AdminDashboard> {
  int _userCount = 0;
  int _orgCount = 0;
  int _activeCount = 0;
  double _totalAmount = 0;
  int _messageCount = 0;
  int _unreadCount = 0;
  int _publishedCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // Run both RPCs independently so one failure doesn't block the other
    final results = await Future.wait([
      ConvocatoriaService.getAdminStats().catchError((_) => <String, dynamic>{}),
      ConvocatoriaService.getStats().catchError((_) => <String, dynamic>{}),
    ]);

    final adminStats = results[0];
    final landingStats = results[1];

    if (mounted) {
      setState(() {
        _userCount = (landingStats['userCount'] as num?)?.toInt() ?? 0;
        _orgCount = (landingStats['orgCount'] as num?)?.toInt() ?? 0;
        _activeCount = (adminStats['active_count'] as num?)?.toInt() ?? 0;
        _totalAmount = (adminStats['total_amount_usd'] as num?)?.toDouble() ?? 0;
        _messageCount = (adminStats['message_count'] as num?)?.toInt() ?? 0;
        _unreadCount = (adminStats['unread_message_count'] as num?)?.toInt() ?? 0;
        _publishedCount = (landingStats['publishedCount'] as num?)?.toInt() ?? 0;
        _loading = false;
      });
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats grid
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _StatCard(
                    icon: Icons.people,
                    value: _loading ? '...' : _userCount.toString(),
                    label: lang == 'es' ? 'Usuarios' : 'Users',
                    color: theme.colorScheme.primary,
                    onTap: () => context.go('/admin/users'),
                  ),
                  _StatCard(
                    icon: Icons.business,
                    value: _loading ? '...' : _orgCount.toString(),
                    label: lang == 'es' ? 'Organizaciones' : 'Organizations',
                    color: const Color(0xFF8b5cf6),
                  ),
                  _StatCard(
                    icon: Icons.campaign,
                    value: _loading ? '...' : _activeCount.toString(),
                    label: lang == 'es' ? 'Activas' : 'Active',
                    color: const Color(0xFF10b981),
                    onTap: () => context.go('/admin/convocatorias'),
                  ),
                  _StatCard(
                    icon: Icons.list_alt,
                    value: _loading ? '...' : _publishedCount.toString(),
                    label: lang == 'es' ? 'Total Publicadas' : 'Total Published',
                    color: const Color(0xFF06b6d4),
                    onTap: () => context.go('/admin/convocatorias'),
                  ),
                  _StatCard(
                    icon: Icons.attach_money,
                    value: _loading ? '...' : _formatAmount(_totalAmount),
                    label: 'USD Total',
                    color: const Color(0xFFF59e0b),
                  ),
                  _StatCard(
                    icon: Icons.email,
                    value: _loading ? '...' : _messageCount.toString(),
                    label: lang == 'es' ? 'Mensajes' : 'Messages',
                    color: const Color(0xFFEf4444),
                    onTap: () => context.go('/admin/messages'),
                  ),
                  _StatCard(
                    icon: Icons.mark_email_unread,
                    value: _loading ? '...' : _unreadCount.toString(),
                    label: lang == 'es' ? 'No leídos' : 'Unread',
                    color: const Color(0xFFF97316),
                    onTap: () => context.go('/admin/messages'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Actions
              Text(
                lang == 'es' ? 'Acciones Rápidas' : 'Quick Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _QuickAction(
                    icon: Icons.add_circle,
                    label: lang == 'es' ? 'Nueva Convocatoria' : 'New Call',
                    color: theme.colorScheme.primary,
                    onTap: () => context.go('/admin/convocatorias/new'),
                  ),
                  _QuickAction(
                    icon: Icons.category,
                    label: lang == 'es' ? 'Categorías' : 'Categories',
                    color: const Color(0xFF8b5cf6),
                    onTap: () => context.go('/admin/categories'),
                  ),
                  _QuickAction(
                    icon: Icons.people,
                    label: lang == 'es' ? 'Usuarios' : 'Users',
                    color: const Color(0xFF06b6d4),
                    onTap: () => context.go('/admin/users'),
                  ),
                  _QuickAction(
                    icon: Icons.email,
                    label: lang == 'es' ? 'Mensajes' : 'Messages',
                    color: const Color(0xFFEf4444),
                    onTap: () => context.go('/admin/messages'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
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
      width: 200,
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 28, color: color),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      onPressed: onTap,
      icon: Icon(icon, color: color),
      label: Text(label),
    );
  }
}
