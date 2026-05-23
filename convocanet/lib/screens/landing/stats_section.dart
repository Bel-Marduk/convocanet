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

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 80, horizontal: isMobile ? 16 : 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4f46e5), Color(0xFF3730a3)],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circle (top-right)
          Positioned(
            top: -250,
            right: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Center(
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
                  spacing: 32,
                  runSpacing: 32,
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
        ],
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
          Icon(icon, size: 32, color: Colors.white.withOpacity(0.8)),
          const SizedBox(height: 12),
          StatCounter(
            target: target,
            prefix: prefix,
            suffix: suffix,
            label: label,
            numberStyle: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 44.8,
              letterSpacing: -1,
              height: 1.1,
            ),
            labelStyle: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
              fontSize: 14.4,
            ),
          ),
        ],
      ),
    );
  }
}
