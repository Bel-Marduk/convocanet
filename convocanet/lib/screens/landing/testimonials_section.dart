import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locale_provider.dart';

class TestimonialsSection extends ConsumerStatefulWidget {
  const TestimonialsSection({super.key});

  @override
  ConsumerState<TestimonialsSection> createState() =>
      _TestimonialsSectionState();
}

class _TestimonialsSectionState extends ConsumerState<TestimonialsSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _testimonials = [
    _TestimonialData(
      textEs:
          '"Gracias a ConvocaNet obtuvimos una beca que transformó nuestro programa de educación comunitaria. La plataforma es intuitiva y las alertas nos mantienen siempre informados."',
      textEn:
          '"Thanks to ConvocaNet we obtained a grant that transformed our community education program. The platform is intuitive and the alerts keep us always informed."',
      name: 'María Rodríguez',
      roleEs: 'Directora, Fundación Educar',
      roleEn: 'Director, Fundación Educar',
      initials: 'MR',
    ),
    _TestimonialData(
      textEs:
          '"La red colaborativa nos permitió encontrar aliados para un proyecto ambiental que ahora impacta a 5 comunidades. Una herramienta indispensable."',
      textEn:
          '"The collaborative network allowed us to find allies for an environmental project that now impacts 5 communities. An indispensable tool."',
      name: 'Carlos López',
      roleEs: 'Coordinador, EcoVerde A.C.',
      roleEn: 'Coordinator, EcoVerde A.C.',
      initials: 'CL',
    ),
    _TestimonialData(
      textEs:
          '"El panel de seguimiento nos da claridad sobre el estado de nuestras postulaciones. Ya no perdemos oportunidades por fechas límite."',
      textEn:
          '"The tracking dashboard gives us clarity on the status of our applications. We no longer miss opportunities due to deadlines."',
      name: 'Ana Patricia Sánchez',
      roleEs: 'Presidenta, Manos Unidas A.C.',
      roleEn: 'President, Manos Unidas A.C.',
      initials: 'AP',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 60 : 100, horizontal: isMobile ? 16 : 24),
      color: isDark
          ? const Color(0xFF1e293b)
          : const Color(0xFFF8fafc),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
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
                  lang == 'es' ? 'TESTIMONIOS' : 'TESTIMONIALS',
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
                    ? 'Lo que dicen las asociaciones'
                    : 'What associations say',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.02,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 56),

              // Carousel
              SizedBox(
                height: 300,
                child: PageView.builder(
                    controller: _pageController,
                    itemCount: _testimonials.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      final t = _testimonials[index];
                      return _TestimonialCard(
                        testimonial: t,
                        lang: lang,
                      );
                    },
                  ),
              ),

              const SizedBox(height: 32),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      color: theme.colorScheme.surface,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                  ...List.generate(
                    _testimonials.length,
                    (index) => GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 28 : 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      color: theme.colorScheme.surface,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TestimonialData {
  final String textEs;
  final String textEn;
  final String name;
  final String roleEs;
  final String roleEn;
  final String initials;

  const _TestimonialData({
    required this.textEs,
    required this.textEn,
    required this.name,
    required this.roleEs,
    required this.roleEn,
    required this.initials,
  });

  String text(String lang) => lang == 'es' ? textEs : textEn;
  String role(String lang) => lang == 'es' ? roleEs : roleEn;
}

class _TestimonialCard extends StatelessWidget {
  final _TestimonialData testimonial;
  final String lang;

  const _TestimonialCard({required this.testimonial, required this.lang});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => const Icon(
                  Icons.star,
                  color: Color(0xFFF59e0b),
                  size: 17.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Text
            Text(
              testimonial.text(lang),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.8,
                fontSize: 16.8,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            // Author
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF4f46e5), Color(0xFF06b6d4)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      testimonial.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.2,
                      ),
                    ),
                    Text(
                      testimonial.role(lang),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 13.12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
