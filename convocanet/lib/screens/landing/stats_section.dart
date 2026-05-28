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
  int _totalAmountUsd = 0;
  int _userCount = 0;
  int _orgCount = 0;
  String? _rateDate;
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
          _totalAmountUsd =
              (stats['totalAmount'] as double? ?? 0).round();
          _userCount = stats['userCount'] as int? ?? 0;
          _orgCount = stats['orgCount'] as int? ?? 0;
          _rateDate = stats['rateDate'] as String?;
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
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
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
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final items = [
                          _StatData(
                            icon: Icons.campaign,
                            target: _publishedCount,
                            label: lang == 'es'
                                ? 'Convocatorias Publicadas'
                                : 'Published Calls',
                          ),
                          _StatData(
                            icon: Icons.attach_money,
                            target: _totalAmountUsd,
                            prefix: 'USD \$',
                            label: lang == 'es'
                                ? 'En Financiamiento (USD)'
                                : 'In Funding (USD)',
                            subtitle: _rateDate != null
                                ? (lang == 'es'
                                    ? 'TC al $_rateDate'
                                    : 'Rate as of $_rateDate')
                                : null,
                          ),
                          _StatData(
                            icon: Icons.business,
                            target: _orgCount,
                            label: lang == 'es'
                                ? 'Organizaciones Registradas'
                                : 'Registered Organizations',
                          ),
                          _StatData(
                            icon: Icons.people,
                            target: _userCount,
                            label: lang == 'es'
                                ? 'Usuarios Registrados'
                                : 'Registered Users',
                          ),
                          _StatData(
                            icon: Icons.public,
                            target: 18,
                            label: lang == 'es'
                                ? 'Estados Conectados'
                                : 'Connected States',
                          ),
                        ];

                        // Responsive column count: min 200px per item
                        final cols = (constraints.maxWidth / 200).floor().clamp(1, items.length);
                        final itemWidth = constraints.maxWidth / cols;

                        return Wrap(
                          alignment: WrapAlignment.center,
                          children: items.map((item) {
                            return SizedBox(
                              width: itemWidth,
                              child: _StatItem(data: item),
                            );
                          }).toList(),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatData {
  final IconData icon;
  final int target;
  final String? prefix;
  final String? suffix;
  final String label;
  final String? subtitle;

  const _StatData({
    required this.icon,
    required this.target,
    this.prefix,
    this.suffix,
    required this.label,
    this.subtitle,
  });
}

class _StatItem extends StatelessWidget {
  final _StatData data;

  const _StatItem({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 32, color: Colors.white.withOpacity(0.8)),
          const SizedBox(height: 12),
          StatCounter(
            target: data.target,
            prefix: data.prefix,
            suffix: data.suffix,
            label: data.label,
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
          if (data.subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              data.subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
