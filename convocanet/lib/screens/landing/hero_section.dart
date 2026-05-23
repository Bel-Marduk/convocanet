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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceVariant.withOpacity(0.5),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background decorations
          Positioned(
            top: -200,
            right: -100,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -50,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.secondary.withOpacity(0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

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
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),
                      child: Text(
                        lang == 'es'
                            ? 'Plataforma de Convocatorias 2026'
                            : 'Open Calls Platform 2026',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Title
                    Text(
                      lang == 'es'
                          ? 'Conectando Asociaciones Civiles\ncon Oportunidades'
                          : 'Connecting Civil Associations\nwith Opportunities',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                        letterSpacing: -0.03,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Subtitle
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: Text(
                        lang == 'es'
                            ? 'Centralizamos las convocatorias públicas y privadas para que tu organización encuentre financiamiento, programas y alianzas estratégicas en un solo lugar.'
                            : 'We centralize public and private calls so your organization can find funding, programs, and strategic partnerships in one place.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.7,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Buttons
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Implement scroll to convocatorias
                          },
                          child: Text(
                            lang == 'es' ? 'Ver Convocatorias' : 'View Open Calls',
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            // TODO: Implement scroll to about
                          },
                          child: Text(
                            lang == 'es' ? 'Conocer Más' : 'Learn More',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 60),

                    // Stats
                    Wrap(
                      spacing: 48,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        StatCounter(
                          target: _userCount,
                          label: lang == 'es' ? 'Usuarios Registrados' : 'Registered Users',
                          numberStyle: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        StatCounter(
                          target: _activeCount,
                          label: lang == 'es' ? 'Convocatorias Activas' : 'Active Calls',
                          numberStyle: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        StatCounter(
                          target: _totalAmountMillions,
                          suffix: 'M',
                          label: lang == 'es' ? 'En Financiamiento' : 'In Funding',
                          numberStyle: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // ... rest of the build method (scroll indicator) remains the same


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
