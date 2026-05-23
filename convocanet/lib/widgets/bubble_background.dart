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
  final List<_Bubble> _bubbles = List.generate(35, (_) => _Bubble());

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
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
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
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

        // Animated Particles
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

        // Subtle glows — top-right
        Positioned(
          top: -200,
          right: -200,
          child: Container(
            width: 800,
            height: 800,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Subtle glows — bottom-left
        Positioned(
          bottom: -200,
          left: -200,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.secondary.withOpacity(isDark ? 0.1 : 0.05),
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
  double size = math.Random().nextDouble() * 6 + 1.5;
  double speed = math.Random().nextDouble() * 0.2 + 0.04;
  double opacity = math.Random().nextDouble() * 0.2 + 0.05;
  double rotation = math.Random().nextDouble() * 720;
  // Oscillation for lateral drift
  double oscillationAmplitude = math.Random().nextDouble() * 40 + 10;
  double oscillationSpeed = math.Random().nextDouble() * 2 + 0.5;
  double phaseOffset = math.Random().nextDouble() * math.pi * 2;
  // 0 = circle, 1 = diamond, 2 = ring
  int shape = math.Random().nextInt(3);
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
    final paint = Paint()..style = PaintingStyle.fill;

    for (var bubble in bubbles) {
      paint.color = (math.Random().nextBool() ? primaryColor : accentColor)
          .withOpacity(bubble.opacity);

      // Vertical movement (wrap around)
      final currentY = (bubble.y * size.height - (animationValue * bubble.speed * size.height)) % size.height;
      // Horizontal oscillation (sine wave drift)
      final sineOffset = math.sin(animationValue * bubble.oscillationSpeed * math.pi * 2 + bubble.phaseOffset) * bubble.oscillationAmplitude;
      final currentX = bubble.x * size.width + sineOffset;
      final currentRotation = animationValue * bubble.rotation;

      canvas.save();
      canvas.translate(currentX, currentY);
      canvas.rotate(currentRotation * math.pi / 180);

      switch (bubble.shape) {
        case 0: // Circle
          canvas.drawCircle(Offset.zero, bubble.size, paint);
          break;
        case 1: // Diamond
          final path = Path()
            ..moveTo(0, -bubble.size)
            ..lineTo(bubble.size, 0)
            ..lineTo(0, bubble.size)
            ..lineTo(-bubble.size, 0)
            ..close();
          canvas.drawPath(path, paint);
          break;
        case 2: // Ring (hollow circle)
          paint.style = PaintingStyle.stroke;
          paint.strokeWidth = 1.2;
          canvas.drawCircle(Offset.zero, bubble.size, paint);
          paint.style = PaintingStyle.fill;
          break;
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
