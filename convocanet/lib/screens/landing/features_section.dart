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
        titleEs: 'Búsqueda Centralizada',
        titleEn: 'Centralized Search',
        descEs: 'Encuentra convocatorias públicas, privadas, concursos, capacitaciones y premios en un solo lugar, priorizando las de México.',
        descEn: 'Find public and private calls, contests, training, and awards in one place, with a focus on Mexico.',
      ),
      _FeatureData(
        icon: Icons.open_in_new,
        titleEs: 'Enlaces Directos',
        titleEn: 'Direct Links',
        descEs: 'Cada convocatoria incluye un enlace directo a la fuente oficial para que te postules sin intermediarios.',
        descEn: 'Each call includes a direct link to the official source so you can apply without intermediaries.',
      ),
      _FeatureData(
        icon: Icons.notifications,
        titleEs: 'Alertas Personalizadas',
        titleEn: 'Custom Alerts',
        descEs: 'Recibe notificaciones cuando se publiquen nuevas convocatorias que coincidan con tu perfil o sector.',
        descEn: 'Get notified when new calls matching your profile or sector are published.',
      ),
      _FeatureData(
        icon: Icons.category,
        titleEs: 'Múltiples Categorías',
        titleEn: 'Multiple Categories',
        descEs: 'Financiamiento, programas gubernamentales, concursos, capacitaciones, premios y más. Para asociaciones civiles y público en general.',
        descEn: 'Funding, government programs, contests, training, awards and more. For civil associations and the general public.',
      ),
      _FeatureData(
        icon: Icons.flag,
        titleEs: 'Prioridad México',
        titleEn: 'Mexico Priority',
        descEs: 'Damos prioridad a convocatorias disponibles para organizaciones y personas en todo México.',
        descEn: 'We prioritize calls available to organizations and individuals across Mexico.',
      ),
      _FeatureData(
        icon: Icons.free_breakfast,
        titleEs: '100% Gratuito',
        titleEn: '100% Free',
        descEs: 'ConvocaNet es completamente gratuito. No cobramos comisiones ni almacenamos documentos.',
        descEn: 'ConvocaNet is completely free. We charge no commissions and do not store documents.',
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
                    ? 'Todo lo que necesitas para encontrar y postularte a convocatorias de forma sencilla y sin intermediarios.'
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
