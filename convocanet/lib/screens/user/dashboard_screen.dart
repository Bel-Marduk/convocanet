import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/convocatoria_card.dart';
import '../../models/convocatoria.dart';
import '../../services/convocatoria_service.dart';
import '../../services/whatsapp_service.dart';
import '../../widgets/user_bottom_nav.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _matchingCount = 0;
  int _favoritesCount = 0;
  double _availableAmount = 0;
  List<Convocatoria> _recommended = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final stats = await ConvocatoriaService.getStats();
      final convocatorias = await ConvocatoriaService.getConvocatorias(limit: 5);

      int favCount = 0;
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final favs = await ConvocatoriaService.getFavorites(user.id);
        favCount = favs.length;
      }

      if (mounted) {
        setState(() {
          _matchingCount = stats['activeCount'] as int? ?? 0;
          _favoritesCount = favCount;
          _availableAmount = stats['totalAmount'] as double? ?? 0;
          _recommended = convocatorias;
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
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          onPressed: () => context.go('/'),
          tooltip: lang == 'es' ? 'Inicio' : 'Home',
        ),
        title: Text(lang == 'es' ? 'Dashboard' : 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.explore),
            onPressed: () => context.go('/convocatorias'),
            tooltip: lang == 'es' ? 'Convocatorias' : 'Browse Calls',
          ),
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () => context.go('/favorites'),
            tooltip: lang == 'es' ? 'Favoritos' : 'Favorites',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
            tooltip: lang == 'es' ? 'Perfil' : 'Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome
                Text(
                  '${lang == 'es' ? 'Bienvenido' : 'Welcome'}, ${profile.value?.fullName ?? ''} 👋',
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
                    _StatCard(
                      icon: Icons.list,
                      value: _loading ? '...' : '$_matchingCount',
                      label: lang == 'es'
                          ? 'Convocatorias Activas'
                          : 'Active Calls',
                      color: theme.colorScheme.primary,
                    ),
                    _StatCard(
                      icon: Icons.star,
                      value: _loading ? '...' : '$_favoritesCount',
                      label: lang == 'es' ? 'Favoritas' : 'Favorites',
                      color: const Color(0xFFF59e0b),
                    ),
                    _StatCard(
                      icon: Icons.attach_money,
                      value: _loading ? '...' : _formatAmount(_availableAmount),
                      label: lang == 'es' ? 'Disponibles' : 'Available',
                      color: const Color(0xFF10b981),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Browse convocatorias button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.explore),
                    label: Text(
                      lang == 'es'
                          ? 'Explorar Convocatorias'
                          : 'Browse All Calls',
                    ),
                    onPressed: () => context.go('/convocatorias'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Recommended convocatorias
                Text(
                  lang == 'es'
                      ? 'Convocatorias Recomendadas'
                      : 'Recommended Calls',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),

                if (_loading)
                  const Center(child: CircularProgressIndicator())
                else if (_recommended.isEmpty)
                  Text(
                    lang == 'es'
                        ? 'No hay convocatorias disponibles.'
                        : 'No calls available.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _recommended
                        .map((c) => SizedBox(
                              width: 350,
                              height: 300,
                              child: ConvocatoriaCard(convocatoria: c),
                            ))
                        .toList(),
                  ),
                const SizedBox(height: 40),

                // Recent alerts
                Text(
                  lang == 'es' ? 'Alertas Recientes' : 'Recent Alerts',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _AlertItem(
                  title: lang == 'es'
                      ? 'Nueva convocatoria: Programa Mujeres Líderes'
                      : 'New call: Women Leaders Program',
                  time: lang == 'es' ? 'Hace 2 horas' : '2 hours ago',
                  lang: lang,
                ),
                _AlertItem(
                  title: lang == 'es'
                      ? 'Nueva convocatoria: Fondo de Innovación Educativa'
                      : 'New call: Educational Innovation Fund',
                  time: lang == 'es' ? 'Hace 5 horas' : '5 hours ago',
                  lang: lang,
                ),
              ],
            ),
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

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 250,
      child: Card(
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
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertItem extends StatelessWidget {
  final String title;
  final String time;
  final String lang;

  const _AlertItem({
    required this.title,
    required this.time,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: Icon(
            Icons.notifications,
            color: theme.colorScheme.primary,
          ),
        ),
        title: Text(title),
        subtitle: Text(time),
        trailing: IconButton(
          icon: const Icon(Icons.share),
          onPressed: () {
            final url = 'https://wa.me/?text=${Uri.encodeComponent(title)}';
            WhatsappService.openWhatsApp(url);
          },
          tooltip: lang == 'es'
              ? 'Notificar por WhatsApp'
              : 'Notify via WhatsApp',
        ),
      ),
    );
  }
}
