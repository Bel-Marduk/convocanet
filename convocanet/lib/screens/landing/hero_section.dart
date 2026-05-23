import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/stat_counter.dart';
import '../../widgets/responsive_layout.dart';
import '../../services/convocatoria_service.dart';

class HeroSection extends ConsumerStatefulWidget {
  const HeroSection({super.key});

  @override
  ConsumerState<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends ConsumerState<HeroSection>
    with TickerProviderStateMixin {
  int _userCount = 1520;
  int _activeCount = 248;
  int _totalAmountMillions = 45;
  bool _loading = true;

  // Staggered entrance animations matching static CSS
  late final AnimationController _badgeCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _subtitleCtrl;
  late final AnimationController _buttonsCtrl;
  late final AnimationController _statsCtrl;

  @override
  void initState() {
    super.initState();
    _loadStats();

    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _subtitleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _buttonsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _statsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Stagger: badge 0ms, title 100ms, subtitle 200ms, buttons 300ms, stats 400ms
    _badgeCtrl.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _titleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _subtitleCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _buttonsCtrl.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _statsCtrl.forward();
    });
  }

  @override
  void dispose() {
    _badgeCtrl.dispose();
    _titleCtrl.dispose();
    _subtitleCtrl.dispose();
    _buttonsCtrl.dispose();
    _statsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await ConvocatoriaService.getStats();
      if (stats.isNotEmpty && mounted) {
        setState(() {
          _userCount = stats['userCount'] as int? ?? 1520;
          _activeCount = stats['activeCount'] as int? ?? 248;
          _totalAmountMillions =
              ((stats['totalAmount'] as double? ?? 45000000) / 1000000).round();
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDark = theme.brightness == Brightness.dark;

    final isMobile = size.width < 768;
    // Max title size: clamp(2.5rem, 6vw, 4.2rem) => max 67.2px
    final titleFontSize = (size.width * 0.06).clamp(32.0, 67.2);

    return SelectionArea(
      child: Container(
        constraints: BoxConstraints(minHeight: size.height - 72),
        color: Colors.transparent,
        child: Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 16 : 24,
                    isMobile ? 60 : 80,
                    isMobile ? 16 : 24,
                    isMobile ? 80 : 120,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Badge — fadeInDown, 0s delay
                      FadeTransition(
                        opacity: _badgeCtrl,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.25),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _badgeCtrl,
                            curve: Curves.easeOut,
                          )),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? theme.colorScheme.surface
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: theme.colorScheme.outlineVariant,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              lang == 'es'
                                  ? 'Agregador Gratuito de Convocatorias'
                                  : 'Free Call Aggregator',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                                fontSize: 13.6,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 20 : 28),

                      // Title — fadeInUp, 0.1s delay
                      FadeTransition(
                        opacity: _titleCtrl,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _titleCtrl,
                            curve: Curves.easeOutCubic,
                          )),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -titleFontSize * 0.03,
                                color: isDark ? Colors.white : const Color(0xFF0f172a),
                                fontSize: titleFontSize,
                              ),
                              children: [
                                TextSpan(
                                  text: lang == 'es' ? 'Conectando ' : 'Connecting ',
                                ),
                                WidgetSpan(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: [
                                        Color(0xFF4f46e5),
                                        Color(0xFF06b6d4),
                                      ],
                                    ).createShader(bounds),
                                    child: Text(
                                      lang == 'es'
                                          ? 'Asociaciones Civiles'
                                          : 'Civil Associations',
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.1,
                                        letterSpacing: -titleFontSize * 0.03,
                                        fontSize: titleFontSize,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: lang == 'es'
                                      ? ' con Oportunidades'
                                      : ' with Opportunities',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 16 : 24),

                      // Subtitle — fadeInUp, 0.2s delay
                      FadeTransition(
                        opacity: _subtitleCtrl,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _subtitleCtrl,
                            curve: Curves.easeOutCubic,
                          )),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: Text(
                              lang == 'es'
                                  ? 'Encuentra convocatorias públicas y privadas de todo el mundo para asociaciones civiles, ONGs y público en general. Financiamiento, programas y capacitaciones con información clave y enlaces directos para postularte sin intermediarios.'
                                  : 'Find public and private calls from around the world for civil associations, NGOs, and the general public. Funding, programs and training with key information and direct links to apply without intermediaries.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: isDark
                                    ? const Color(0xFFcbd5e1)
                                    : const Color(0xFF475569),
                                height: 1.7,
                                fontWeight: FontWeight.w400,
                                fontSize: isMobile ? 15.2 : 18.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 24 : 36),

                      // Buttons — fadeInUp, 0.3s delay
                      FadeTransition(
                        opacity: _buttonsCtrl,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _buttonsCtrl,
                            curve: Curves.easeOutCubic,
                          )),
                          child: Wrap(
                            spacing: isMobile ? 12 : 16,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4f46e5),
                                      Color(0xFF3730a3),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4f46e5)
                                          .withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    lang == 'es'
                                        ? 'Explorar Convocatorias'
                                        : 'Explore Calls',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.2,
                                    ),
                                  ),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: isDark
                                        ? Colors.white.withOpacity(0.3)
                                        : const Color(0xFFe2e8f0),
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  lang == 'es' ? 'Conocer Más' : 'Learn More',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.2,
                                    color:
                                        isDark ? Colors.white : const Color(0xFF0f172a),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: isMobile ? 40 : 60),

                      // Stats — fadeInUp, 0.4s delay
                      FadeTransition(
                        opacity: _statsCtrl,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _statsCtrl,
                            curve: Curves.easeOutCubic,
                          )),
                          child: Wrap(
                            spacing: isMobile ? 24 : 48,
                            runSpacing: isMobile ? 24 : 40,
                            alignment: WrapAlignment.center,
                            children: [
                              StatCounter(
                                target: _activeCount,
                                label: lang == 'es'
                                    ? 'Convocatorias Registradas'
                                    : 'Registered Calls',
                                numberStyle: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                  fontSize: 35.2,
                                  height: 1.2,
                                ),
                                labelStyle: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13.6,
                                ),
                              ),
                              StatCounter(
                                target: _userCount,
                                label: lang == 'es'
                                    ? 'Asociaciones Registradas'
                                    : 'Registered Associations',
                                numberStyle: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                  fontSize: 35.2,
                                  height: 1.2,
                                ),
                                labelStyle: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13.6,
                                ),
                              ),
                              StatCounter(
                                target: 89,
                                suffix: '%',
                                label: lang == 'es'
                                    ? 'Tasa de Éxito'
                                    : 'Success Rate',
                                numberStyle: theme.textTheme.headlineMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: theme.colorScheme.primary,
                                  fontSize: 35.2,
                                  height: 1.2,
                                ),
                                labelStyle: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 13.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Scroll indicator
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: 26,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.onSurfaceVariant
                          .withOpacity(0.4),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Container(
                      width: 4,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant
                            .withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const _ScrollAnimation(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScrollAnimation extends StatefulWidget {
  const _ScrollAnimation();

  @override
  State<_ScrollAnimation> createState() => _ScrollAnimationState();
}

class _ScrollAnimationState extends State<_ScrollAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: 0, end: 12).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 4,
            height: 8,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}
