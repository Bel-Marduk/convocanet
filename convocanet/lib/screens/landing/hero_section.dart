import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    with SingleTickerProviderStateMixin {
  int _userCount = 1520; // Fallback defaults
  int _activeCount = 248;
  int _totalAmountMillions = 45;
  bool _loading = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

    return SelectionArea(
      child: Container(
        constraints: BoxConstraints(minHeight: size.height - 72),
        color: Colors.transparent,
        child: Stack(
          children: [
            // Content
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: theme.colorScheme.primary.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              lang == 'es'
                                  ? 'PLATAFORMA DE CONVOCATORIAS 2026'
                                  : 'OPEN CALLS PLATFORM 2026',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: theme.colorScheme.primary,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Title
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: theme.textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                                letterSpacing: -1.5,
                                color: isDark ? Colors.white : Colors.black87,
                                fontSize: 76,
                              ),
                              children: [
                                TextSpan(
                                  text: lang == 'es' ? 'Conectando ' : 'Connecting ',
                                ),
                                WidgetSpan(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) => const LinearGradient(
                                      colors: [Color(0xFF6366f1), Color(0xFF06b6d4)],
                                    ).createShader(bounds),
                                    child: Text(
                                      lang == 'es' ? 'Asociaciones Civiles' : 'Civil Associations',
                                      style: theme.textTheme.displayLarge?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        height: 1.1,
                                        letterSpacing: -1.5,
                                        fontSize: 76,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(
                                  text: lang == 'es' ? '\ncon Oportunidades' : '\nwith Opportunities',
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // Subtitle
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 800),
                            child: Text(
                              lang == 'es'
                                  ? 'Centralizamos las convocatorias públicas para que tu organización encuentre financiamiento, programas y alianzas estratégicas en un solo lugar.'
                                  : 'We centralize public calls so your organization can find funding, programs, and strategic partnerships in one place.',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: isDark ? Colors.white.withOpacity(0.7) : Colors.black54,
                                height: 1.7,
                                fontWeight: FontWeight.w400,
                                fontSize: 21,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 64),

                          // Buttons
                          Wrap(
                            spacing: 24,
                            runSpacing: 20,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Scroll implementation
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4f46e5),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 26),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 20,
                                  shadowColor: const Color(0xFF4f46e5).withOpacity(0.4),
                                ),
                                child: Text(
                                  lang == 'es' ? 'Ver Convocatorias' : 'View Open Calls',
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                                ),
                              ),
                              OutlinedButton(
                                onPressed: () {
                                  // TODO: Scroll implementation
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 26),
                                  side: BorderSide(color: isDark ? Colors.white.withOpacity(0.3) : Colors.black26, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Text(
                                  lang == 'es' ? 'Conocer Más' : 'Learn More',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800, 
                                    fontSize: 18,
                                    color: isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 80),

                          // Stats
                          Wrap(
                            spacing: 80,
                            runSpacing: 40,
                            alignment: WrapAlignment.center,
                            children: [
                              StatCounter(
                                target: _activeCount,
                                label: lang == 'es' ? 'Convocatorias Activas' : 'Active Calls',
                                numberStyle: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                  fontSize: 42,
                                  letterSpacing: -1,
                                ),
                              ),
                              StatCounter(
                                target: _userCount,
                                label: lang == 'es' ? 'Asociaciones Registradas' : 'Registered Associations',
                                numberStyle: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                  fontSize: 42,
                                  letterSpacing: -1,
                                ),
                              ),
                              StatCounter(
                                target: 89,
                                suffix: '%',
                                label: lang == 'es' ? 'Tasa de Éxito' : 'Success Rate',
                                numberStyle: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                  fontSize: 42,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
                child: Column(
                  children: [
                    Container(
                      width: 26,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: const _ScrollAnimation(),
                        ),
                      ),
                    ),
                  ],
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
