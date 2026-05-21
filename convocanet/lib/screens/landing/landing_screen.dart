import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/navbar.dart';
import 'hero_section.dart';
import 'features_section.dart';
import 'convocatorias_section.dart';
import 'stats_section.dart';
import 'testimonials_section.dart';
import 'contact_section.dart';
import '../../widgets/responsive_layout.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void scrollToContact() {
    // Approximate offset: hero(~600) + features(~400) + convocatorias(~600) + stats(~400) + testimonials(~400) + CTA(~400)
    // We scroll to the end since contact is the last section before footer
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          return false;
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Navbar
            const SliverAppBar(
              floating: true,
              pinned: true,
              automaticallyImplyLeading: false,
              title: Navbar(),
            ),

            // Hero Section
            const SliverToBoxAdapter(
              child: HeroSection(),
            ),

            // Features Section
            const SliverToBoxAdapter(
              child: FeaturesSection(),
            ),

            // Convocatorias Section
            const SliverToBoxAdapter(
              child: ConvocatoriasSection(),
            ),

            // Stats Section
            const SliverToBoxAdapter(
              child: StatsSection(),
            ),

            // Testimonials Section
            const SliverToBoxAdapter(
              child: TestimonialsSection(),
            ),

            // CTA Section
            SliverToBoxAdapter(
              child: _CTASection(),
            ),

            // Contact Section
            const SliverToBoxAdapter(
              child: ContactSection(),
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
    final lang = ref.watch(ref.read(localeProvider.notifier).select((n) => n.currentLang));
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      color: theme.colorScheme.surface,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 640),
          padding: const EdgeInsets.all(64),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4f46e5), Color(0xFF3730a3)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Text(
                lang == 'es'
                    ? '¿Listo para encontrar tu próxima convocatoria?'
                    : 'Ready to find your next open call?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                lang == 'es'
                    ? 'Únete a asociaciones civiles que ya están aprovechando estas oportunidades.'
                    : 'Join civil associations already taking advantage of these opportunities.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _scrollToContact(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4f46e5),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  lang == 'es' ? 'Comenzar Ahora' : 'Get Started',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToContact(BuildContext context) {
    // TODO: Implement smooth scroll to contact section
  }
}

class _Footer extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(ref.read(localeProvider.notifier).select((n) => n.currentLang));
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          // Footer grid
          Wrap(
            spacing: 60,
            runSpacing: 40,
            alignment: WrapAlignment.spaceBetween,
            children: [
              // Brand
              SizedBox(
                width: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.campaign, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'ConvocaNet',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang == 'es'
                          ? 'Conectando asociaciones civiles con oportunidades de financiamiento y desarrollo.'
                          : 'Connecting civil associations with funding and development opportunities.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                  (lang == 'es' ? 'Guías' : 'Guides', () {}),
                  ('FAQ', () {}),
                  ('API', () {}),
                ],
              ),

              // Legal
              _FooterColumn(
                title: lang == 'es' ? 'Legal' : 'Legal',
                links: [
                  (lang == 'es' ? 'Privacidad' : 'Privacy', () {}),
                  (lang == 'es' ? 'Términos' : 'Terms', () {}),
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
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.05,
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
