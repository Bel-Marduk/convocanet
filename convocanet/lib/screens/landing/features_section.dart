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
        descEs: 'Encuentra convocatorias públicas y privadas de todo el mundo: financiamiento, programas y capacitaciones.',
        descEn: 'Find public and private calls from around the world: funding, programs and training.',
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
        descEs: 'Financiamiento, programas, capacitaciones y más. Para asociaciones civiles, ONGs y público en general.',
        descEn: 'Funding, programs, training and more. For civil associations, NGOs, and the general public.',
      ),
      _FeatureData(
        icon: Icons.flag,
        titleEs: 'Prioridad América Latina',
        titleEn: 'Latin America Priority',
        descEs: 'Convocatorias de todo el mundo con prioridad a las que apliquen para México y Latinoamérica.',
        descEn: 'Calls from around the world with priority given to those applicable in Mexico and Latin America.',
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
                    ? 'Encuentra convocatorias de todo el mundo y postúlate directamente con quien las emite, sin intermediarios.'
                    : 'Tools designed to simplify searching and applying to open calls.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 56),

              // Features grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 700
                      ? 1
                      : constraints.maxWidth < 1050
                          ? 2
                          : 3;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: crossAxisCount == 1 ? 2.5 : 1.5,
                    ),
                    itemCount: features.length,
                    itemBuilder: (context, i) => _FeatureCard(
                      feature: features[i],
                      lang: lang,
                    ),
                  );
                },
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

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        padding: const EdgeInsets.all(36),
        transform: _hovering
            ? (Matrix4.identity()..translate(0.0, -6.0))
            : Matrix4.identity(),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _hovering
                ? theme.colorScheme.primary.withOpacity(0.4)
                : theme.colorScheme.outlineVariant,
          ),
          boxShadow: _hovering
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.12),
                    blurRadius: 24,
                    spreadRadius: -2,
                    offset: const Offset(0, 12),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
                    blurRadius: 8,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
                    blurRadius: 6,
                    spreadRadius: -2,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                scale: _hovering ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: Icon(
                  widget.feature.icon,
                  color: _hovering ? Colors.white : theme.colorScheme.primary,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.feature.title(widget.lang),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.feature.desc(widget.lang),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
