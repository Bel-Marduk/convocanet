import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/stat_counter.dart';

class StatsSection extends ConsumerWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4f46e5), Color(0xFF3730a3)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Wrap(
            spacing: 32,
            runSpacing: 32,
            alignment: WrapAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.campaign,
                target: 1250,
                label: lang == 'es' ? 'Convocatorias Publicadas' : 'Published Calls',
              ),
              _StatItem(
                icon: Icons.attach_money,
                target: 45,
                suffix: 'M',
                prefix: '\$',
                label: lang == 'es' ? 'En Financiamiento' : 'In Funding',
              ),
              _StatItem(
                icon: Icons.business,
                target: 320,
                label: lang == 'es' ? 'Organizaciones Activas' : 'Active Organizations',
              ),
              _StatItem(
                icon: Icons.public,
                target: 18,
                label: lang == 'es' ? 'Estados Conectados' : 'Connected States',
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
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.white70),
          const SizedBox(height: 12),
          StatCounter(
            target: target,
            prefix: prefix,
            suffix: suffix,
            label: label,
            numberStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
