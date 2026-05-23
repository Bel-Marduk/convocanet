import 'dart:math' as math;
import 'package:flutter/material.dart';

class BubbleBackground extends StatefulWidget {
  final Widget child;
  const BubbleBackground({super.key, required this.child});

  @override
  State<BubbleBackground> createState() => _BubbleBackgroundState();
}

class _BubbleBackgroundState extends State<BubbleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Bubble> _bubbles = List.generate(15, (_) => _Bubble());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Background Gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        const Color(0xFF0f172a),
                        const Color(0xFF1e293b),
                        const Color(0xFF0f172a),
                      ]
                    : [
                        const Color(0xFFffffff),
                        const Color(0xFFf8fafc),
                        const Color(0xFFffffff),
                      ],
              ),
            ),
          ),
        ),

        // Animated Bubbles
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _BubblePainter(
                  bubbles: _bubbles,
                  animationValue: _controller.value,
                  isDark: isDark,
                  primaryColor: theme.colorScheme.primary,
                  accentColor: theme.colorScheme.secondary,
                ),
              );
            },
          ),
        ),

        // Glow effects (similar to CSS ::before and ::after)
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
                  theme.colorScheme.primary.withOpacity(isDark ? 0.12 : 0.05),
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
                  theme.colorScheme.secondary.withOpacity(isDark ? 0.08 : 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Content
        widget.child,
      ],
    );
  }
}

class _Bubble {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double size = math.Random().nextDouble() * 100 + 50;
  double speed = math.Random().nextDouble() * 0.2 + 0.1;
  double opacity = math.Random().nextDouble() * 0.1 + 0.05;
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double animationValue;
  final bool isDark;
  final Color primaryColor;
  final Color accentColor;

  _BubblePainter({
    required this.bubbles,
    required this.animationValue,
    required this.isDark,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var bubble in bubbles) {
      final paint = Paint()
        ..color = (math.Random().nextBool() ? primaryColor : accentColor)
            .withOpacity(bubble.opacity);
      
      final currentY = (bubble.y * size.height - (animationValue * bubble.speed * size.height)) % size.height;
      final currentX = bubble.x * size.width + math.sin(animationValue * math.pi * 2 + bubble.y * 10) * 20;

      canvas.drawCircle(Offset(currentX, currentY), bubble.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
