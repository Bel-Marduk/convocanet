import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/navbar.dart';
import '../../widgets/bubble_background.dart';
import 'hero_section.dart';
import 'what_section.dart';
import 'features_section.dart';
import 'convocatorias_section.dart';
import 'stats_section.dart';
import 'testimonials_section.dart';
import 'newsletter_section.dart';
import 'contact_section.dart';
import '../../widgets/responsive_layout.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final ScrollController _scrollController = ScrollController();

  // GlobalKeys for each section
  final _featuresKey = GlobalKey();
  final _convocatoriasKey = GlobalKey();
  final _statsKey = GlobalKey();
  final _testimonialsKey = GlobalKey();
  final _contactKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToSection(String sectionId) {
    GlobalKey? key;
    switch (sectionId) {
      case 'inicio':
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut);
        return;
      case 'caracteristicas':
        key = _featuresKey;
        break;
      case 'convocatorias':
        key = _convocatoriasKey;
        break;
      case 'estadisticas':
        key = _statsKey;
        break;
      case 'nosotros':
        key = _testimonialsKey;
        break;
      case 'contacto':
        key = _contactKey;
        break;
    }
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
    }
  }

  void scrollToContact() => scrollToSection('contacto');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BubbleBackground(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Navbar
            SliverAppBar(
              floating: true,
              pinned: true,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              toolbarHeight: 72,
              flexibleSpace: Navbar(onNavigate: scrollToSection),
            ),
            // Hero Section
            SliverToBoxAdapter(
              child: HeroSection(onNavigate: scrollToSection),
            ),

            // What is ConvocaNet Section
            const SliverToBoxAdapter(
              child: WhatSection(),
            ),

            // Features Section
            SliverToBoxAdapter(
              child: Container(key: _featuresKey, child: const FeaturesSection()),
            ),

            // Convocatorias Section
            SliverToBoxAdapter(
              child: Container(key: _convocatoriasKey, child: const ConvocatoriasSection()),
            ),

            // Stats Section
            SliverToBoxAdapter(
              child: Container(key: _statsKey, child: const StatsSection()),
            ),

            // Testimonials Section
            SliverToBoxAdapter(
              child: Container(key: _testimonialsKey, child: const TestimonialsSection()),
            ),

            // Newsletter Section
            const SliverToBoxAdapter(
              child: NewsletterSection(),
            ),

            // CTA Section
            SliverToBoxAdapter(
              child: _CTASection(),
            ),

            // Contact Section
            SliverToBoxAdapter(
              child: Container(key: _contactKey, child: const ContactSection()),
            ),

            // Footer
            SliverToBoxAdapter(
              child: _Footer(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CTASection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: isMobile ? 16 : 24),
      color: theme.colorScheme.background,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 640),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF4f46e5), Color(0xFF3730a3)],
              ),
            ),
            child: Stack(
              children: [
                // Decorative circle
                Positioned(
                  top: -100,
                  right: -100,
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 48 : 64, horizontal: isMobile ? 24 : 40),
                  child: Column(
            children: [
              Text(
                lang == 'es'
                    ? '¿Listo para encontrar tu próxima convocatoria?'
                    : 'Ready to find your next call?',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.02,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'es'
                    ? 'Encuentra convocatorias de todo el mundo. Totalmente gratuito.'
                    : 'Find calls from around the world. Completely free.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6,
                  fontSize: 16.8,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  final state = context.findAncestorStateOfType<_LandingScreenState>();
                  state?.scrollToContact();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4f46e5),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: Colors.black.withOpacity(0.15),
                ),
                child: Text(
                  lang == 'es' ? 'Comenzar Ahora' : 'Get Started',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15.2,
                  ),
                ),
              ),
                  ],
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

class _Footer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      color: isDark ? const Color(0xFF1e293b) : const Color(0xFFf1f5f9),
      child: Column(
        children: [
          // Footer grid
          Wrap(
            spacing: 40,
            runSpacing: 40,
            alignment: WrapAlignment.center,
            children: [
              // Brand
              SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign, color: theme.colorScheme.primary, size: 20.8),
                        const SizedBox(width: 10),
                        Text(
                          'ConvocaNet',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                            fontSize: 22.4,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      lang == 'es'
                          ? 'Agregador gratuito de convocatorias públicas y privadas para asociaciones civiles, ONGs y público en general. Enlaces directos a la fuente original.'
                          : 'Free aggregator of public and private calls for civil associations, NGOs, and the general public. Direct links to the original source.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.7,
                        fontSize: 14.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Platform links
              _FooterColumn(
                title: lang == 'es' ? 'Plataforma' : 'Platform',
                links: [
                  (lang == 'es' ? 'Convocatorias' : 'Open Calls', () {}),
                  (lang == 'es' ? 'Características' : 'Features', () {}),
                  (lang == 'es' ? 'Estadísticas' : 'Statistics', () {}),
                  (lang == 'es' ? 'Nosotros' : 'About', () {}),
                ],
              ),

              // Resources
              _FooterColumn(
                title: lang == 'es' ? 'Recursos' : 'Resources',
                links: [
                  ('Blog', () {}),
                  (lang == 'es' ? 'Guías de Postulación' : 'Application Guides', () {}),
                  (lang == 'es' ? 'Preguntas Frecuentes' : 'FAQ', () {}),
                  ('API', () {}),
                ],
              ),

              // Legal
              _FooterColumn(
                title: lang == 'es' ? 'Legal' : 'Legal',
                links: [
                  (lang == 'es' ? 'Privacidad' : 'Privacy', () {}),
                  (lang == 'es' ? 'Términos de Uso' : 'Terms of Use', () {}),
                  ('Cookies', () {}),
                ],
              ),
            ],
          ),

          const SizedBox(height: 40),

          // Bottom
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                ),
              ),
            ),
            child: Center(
              child: Text(
                lang == 'es'
                    ? '© 2026 ConvocaNet. Todos los derechos reservados.'
                    : '© 2026 ConvocaNet. All rights reserved.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 13.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterColumn extends StatelessWidget {
  final String title;
  final List<(String, VoidCallback)> links;

  const _FooterColumn({required this.title, required this.links});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.05,
              fontSize: 14.4,
            ),
          ),
          const SizedBox(height: 16),
          ...links.map((link) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: link.$2,
                    child: Text(
                      link.$1,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14.4,
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
