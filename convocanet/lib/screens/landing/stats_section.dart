import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/stat_counter.dart';
import '../../services/convocatoria_service.dart';

class StatsSection extends ConsumerStatefulWidget {
  const StatsSection({super.key});

  @override
  ConsumerState<StatsSection> createState() => _StatsSectionState();
}

class _StatsSectionState extends ConsumerState<StatsSection> {
  int _publishedCount = 0;
  int _totalAmountMillions = 0;
  int _userCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ConvocatoriaService.getStats();
      if (mounted) {
        setState(() {
          _publishedCount = stats['publishedCount'] as int? ?? 0;
          _totalAmountMillions =
              ((stats['totalAmount'] as double? ?? 0) / 1000000).round();
          _userCount = stats['userCount'] as int? ?? 0;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      color: Colors.transparent,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: _loading
              ? const SizedBox(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : Wrap(
                  spacing: 48,
                  runSpacing: 48,
                  alignment: WrapAlignment.spaceAround,
                  children: [
                    _StatItem(
                      icon: Icons.campaign,
                      target: _publishedCount,
                      label: lang == 'es'
                          ? 'Convocatorias Publicadas'
                          : 'Published Calls',
                    ),
                    _StatItem(
                      icon: Icons.attach_money,
                      target: _totalAmountMillions,
                      suffix: 'M',
                      prefix: '\$',
                      label:
                          lang == 'es' ? 'En Financiamiento' : 'In Funding',
                    ),
                    _StatItem(
                      icon: Icons.business,
                      target: _userCount,
                      label: lang == 'es'
                          ? 'Organizaciones Activas'
                          : 'Active Organizations',
                    ),
                    _StatItem(
                      icon: Icons.public,
                      target: 18,
                      label: lang == 'es'
                          ? 'Estados Conectados'
                          : 'Connected States',
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int target;
  final String? prefix;
  final String? suffix;
  final String label;

  const _StatItem({
    required this.icon,
    required this.target,
    this.prefix,
    this.suffix,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 220,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: theme.colorScheme.primary),
          ),
          const SizedBox(height: 20),
          StatCounter(
            target: target,
            prefix: prefix,
            suffix: suffix,
            label: label,
            numberStyle: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
              letterSpacing: -1,
            ),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
