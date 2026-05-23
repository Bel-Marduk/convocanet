import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';

class FeaturesSection extends ConsumerWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: isMobile ? 16 : 24),
      color: theme.brightness == Brightness.dark
          ? const Color(0xFF1e293b)
          : const Color(0xFFF8fafc),
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
                      theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                      theme.colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.1),
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

class _FeatureCard extends StatefulWidget {
  final _FeatureData feature;
  final String lang;

  const _FeatureCard({required this.feature, required this.lang});

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth < 400 ? screenWidth - 48.0 : 350.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: cardWidth,
        padding: const EdgeInsets.all(36),
        transform: _hovering
            ? (Matrix4.identity()..translate(0.0, -4.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovering
                ? Colors.transparent
                : theme.colorScheme.outlineVariant,
          ),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.5 : 0.08),
                    blurRadius: 15,
                    spreadRadius: -3,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
                    blurRadius: 6,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon with hover scale and gradient effect
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: _hovering
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4f46e5), Color(0xFF06b6d4)],
                      )
                    : LinearGradient(
                        colors: [
                          theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                          theme.colorScheme.secondary.withOpacity(isDark ? 0.2 : 0.1),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedScale(
                scale: _hovering ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Icon(
                  widget.feature.icon,
                  color: _hovering ? Colors.white : theme.colorScheme.primary,
                  size: 20.8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.feature.title(widget.lang),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.feature.desc(widget.lang),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.7,
                fontSize: 14.72,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
