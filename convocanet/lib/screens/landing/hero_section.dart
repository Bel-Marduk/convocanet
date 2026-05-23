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

class _HeroSectionState extends ConsumerState<HeroSection> {
  int _userCount = 1520; // Fallback defaults
  int _activeCount = 248;
  int _totalAmountMillions = 45;
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

    return Container(
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
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        lang == 'es'
                            ? 'PLATAFORMA DE CONVOCATORIAS 2026'
                            : 'OPEN CALLS PLATFORM 2026',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.primary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                          letterSpacing: -0.05,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        children: [
                          TextSpan(
                            text: lang == 'es' ? 'Conectando ' : 'Connecting ',
                          ),
                          WidgetSpan(
                            child: ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [Color(0xFF4f46e5), Color(0xFF06b6d4)],
                              ).createShader(bounds),
                              child: Text(
                                lang == 'es' ? 'Asociaciones Civiles' : 'Civil Associations',
                                style: theme.textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  height: 1.05,
                                  letterSpacing: -0.05,
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

                    const SizedBox(height: 32),

                    // Subtitle
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Text(
                        lang == 'es'
                            ? 'Centralizamos las convocatorias públicas para que tu organización encuentre financiamiento, programas y alianzas estratégicas en un solo lugar.'
                            : 'We centralize public calls so your organization can find funding, programs, and strategic partnerships in one place.',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                          height: 1.7,
                          fontWeight: FontWeight.w400,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),


                    const SizedBox(height: 48),

                    // Buttons
                    Wrap(
                      spacing: 20,
                      runSpacing: 20,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement scroll to convocatorias
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            lang == 'es' ? 'Ver Convocatorias' : 'View Open Calls',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Implement scroll to about
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 22),
                            side: BorderSide(color: theme.colorScheme.outlineVariant, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(
                            lang == 'es' ? 'Conocer Más' : 'Learn More',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 80),

                    // Stats
                    Wrap(
                      spacing: 64,
                      runSpacing: 32,
                      alignment: WrapAlignment.center,
                      children: [
                        StatCounter(
                          target: _userCount,
                          label: lang == 'es' ? 'Usuarios Registrados' : 'Registered Users',
                          numberStyle: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            fontSize: 36,
                          ),
                        ),
                        StatCounter(
                          target: _activeCount,
                          label: lang == 'es' ? 'Convocatorias Activas' : 'Active Calls',
                          numberStyle: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            fontSize: 36,
                          ),
                        ),
                        StatCounter(
                          target: _totalAmountMillions,
                          suffix: 'M',
                          label: lang == 'es' ? 'En Financiamiento' : 'In Funding',
                          numberStyle: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: theme.colorScheme.primary,
                            fontSize: 36,
                          ),
                        ),
                      ],
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _controller.value * 12),
          child: Opacity(
            opacity: 1 - _controller.value,
            child: child,
          ),
        );
      },
      child: Container(
        width: 4,
        height: 8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
