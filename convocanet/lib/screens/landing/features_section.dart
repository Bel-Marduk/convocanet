import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';

class FeaturesSection extends ConsumerWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    final features = [
      _FeatureData(
        icon: Icons.search,
        titleEs: 'Búsqueda Inteligente',
        titleEn: 'Smart Search',
        descEs: 'Filtra convocatorias por sector, monto, región y fecha límite.',
        descEn: 'Filter calls by sector, amount, region, and deadline.',
      ),
      _FeatureData(
        icon: Icons.notifications,
        titleEs: 'Alertas por WhatsApp',
        titleEn: 'WhatsApp Alerts',
        descEs: 'Recibe notificaciones personalizadas cuando se publiquen nuevas convocatorias.',
        descEn: 'Receive personalized notifications when new calls are published.',
      ),
      _FeatureData(
        icon: Icons.description,
        titleEs: 'Gestión Documental',
        titleEn: 'Document Management',
        descEs: 'Almacena y organiza todos los documentos necesarios para tus postulaciones.',
        descEn: 'Store and organize all documents needed for your applications.',
      ),
      _FeatureData(
        icon: Icons.dashboard,
        titleEs: 'Panel de Seguimiento',
        titleEn: 'Tracking Dashboard',
        descEs: 'Monitorea el estado de todas tus postulaciones en tiempo real.',
        descEn: 'Monitor the status of all your applications in real time.',
      ),
      _FeatureData(
        icon: Icons.people,
        titleEs: 'Red Colaborativa',
        titleEn: 'Collaborative Network',
        descEs: 'Conecta con otras asociaciones civiles para formar alianzas estratégicas.',
        descEn: 'Connect with other civil associations to form strategic alliances.',
      ),
      _FeatureData(
        icon: Icons.shield,
        titleEs: 'Transparencia Total',
        titleEn: 'Full Transparency',
        descEs: 'Cada convocatoria incluye criterios de evaluación e historial de resultados.',
        descEn: 'Each call includes evaluation criteria and results history.',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.secondary.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  lang == 'es' ? 'CARACTERÍSTICAS' : 'FEATURES',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.primary,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'es'
                    ? 'Todo lo que necesitas en un solo lugar'
                    : 'Everything you need in one place',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.02,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'es'
                    ? 'Herramientas diseñadas para simplificar la búsqueda y postulación a convocatorias.'
                    : 'Tools designed to simplify searching and applying to open calls.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 56),

              // Features grid
              Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: features
                    .map((f) => _FeatureCard(
                          feature: f,
                          lang: lang,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String titleEs;
  final String titleEn;
  final String descEs;
  final String descEn;

  const _FeatureData({
    required this.icon,
    required this.titleEs,
    required this.titleEn,
    required this.descEs,
    required this.descEn,
  });

  String title(String lang) => lang == 'es' ? titleEs : titleEn;
  String desc(String lang) => lang == 'es' ? descEs : descEn;
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData feature;
  final String lang;

  const _FeatureCard({required this.feature, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 350,
        padding: const EdgeInsets.all(36),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                feature.icon,
                color: theme.colorScheme.primary,
                size: 26,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              feature.title(lang),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              feature.desc(lang),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
