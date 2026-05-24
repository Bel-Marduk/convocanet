import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/locale_provider.dart';

class WhatSection extends ConsumerWidget {
  const WhatSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider).languageCode;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 60 : 100,
        horizontal: isMobile ? 16 : 24,
      ),
      color: isDark ? const Color(0xFF1e293b) : const Color(0xFFF8fafc),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // Decorative icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(isDark ? 0.3 : 0.15),
                      theme.colorScheme.secondary.withOpacity(isDark ? 0.3 : 0.15),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.public_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.02,
                    height: 1.2,
                  ),
                  children: [
                    TextSpan(
                      text: lang == 'es' ? 'Qué es ' : 'What is ',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0f172a),
                      ),
                    ),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFF4f46e5), Color(0xFF06b6d4)],
                        ).createShader(bounds),
                        child: Text(
                          'ConvocaNet',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.02,
                            height: 1.2,
                            fontSize: (theme.textTheme.headlineMedium?.fontSize ?? 28),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang == 'es'
                    ? 'y por qué te conviene usarlo'
                    : 'and why you should use it',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                  fontSize: isMobile ? 18 : 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Description
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.8,
                      fontSize: isMobile ? 15.2 : 17.6,
                    ),
                    children: [
                      TextSpan(
                        text: lang == 'es'
                            ? 'Nuestro propósito es '
                            : 'Our purpose is to ',
                      ),
                      TextSpan(
                        text: lang == 'es'
                            ? 'Conectar y Centralizar'
                            : 'Connect and Centralize',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextSpan(
                        text: lang == 'es'
                            ? ' un mundo de oportunidades para asociaciones civiles, ONGs y público en general, facilitando el acceso a financiamiento, programas y capacitaciones '
                            : ' a world of opportunities for civil associations, NGOs, and the general public, facilitating access to funding, programs and training ',
                      ),
                      TextSpan(
                        text: lang == 'es'
                            ? 'sin intermediarios y completamente gratis.'
                            : 'without intermediaries and completely free.',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Buttons
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                    label: Text(
                      lang == 'es' ? 'Cómo funciona' : 'How it works',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
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
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.analytics_outlined, size: 18),
                    label: Text(
                      lang == 'es'
                          ? 'Indicadores de Impacto'
                          : 'Impact Indicators',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
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
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Decorative network illustration
              SizedBox(
                height: 120,
                child: CustomPaint(
                  size: const Size(400, 120),
                  painter: _NetworkPainter(
                    color: theme.colorScheme.primary.withOpacity(isDark ? 0.25 : 0.15),
                    dotColor: theme.colorScheme.primary.withOpacity(isDark ? 0.5 : 0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NetworkPainter extends CustomPainter {
  final Color color;
  final Color dotColor;

  _NetworkPainter({required this.color, required this.dotColor});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    // Generate deterministic node positions
    final nodes = <Offset>[
      Offset(size.width * 0.1, size.height * 0.5),
      Offset(size.width * 0.25, size.height * 0.2),
      Offset(size.width * 0.35, size.height * 0.7),
      Offset(size.width * 0.5, size.height * 0.35),
      Offset(size.width * 0.6, size.height * 0.65),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.9, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.5),
    ];

    // Draw lines between connected nodes
    final connections = [
      [0, 1], [0, 3], [1, 3], [1, 5],
      [2, 3], [2, 4], [3, 4], [3, 5],
      [4, 6], [5, 6], [0, 7], [7, 4],
      [3, 8], [8, 6],
    ];

    for (final conn in connections) {
      canvas.drawLine(nodes[conn[0]], nodes[conn[1]], linePaint);
    }

    // Draw dots at nodes
    for (final node in nodes) {
      canvas.drawCircle(node, 4, dotPaint);
    }

    // Draw a few larger accent dots
    final accentPaint = Paint()
      ..color = dotColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(nodes[3], 6, accentPaint);
    canvas.drawCircle(nodes[6], 6, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
