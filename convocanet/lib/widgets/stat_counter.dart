import 'package:flutter/material.dart';

class StatCounter extends StatefulWidget {
  final int target;
  final String label;
  final String? prefix;
  final String? suffix;
  final Duration duration;
  final TextStyle? numberStyle;
  final TextStyle? labelStyle;

  const StatCounter({
    super.key,
    required this.target,
    required this.label,
    this.prefix,
    this.suffix,
    this.duration = const Duration(milliseconds: 2000),
    this.numberStyle,
    this.labelStyle,
  });

  @override
  State<StatCounter> createState() => _StatCounterState();
}

class _StatCounterState extends State<StatCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.target.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (!_hasAnimated) {
      _hasAnimated = true;
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value.toInt();
        final formatted = value.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.prefix ?? ''}$formatted${widget.suffix ?? ''}',
              style: widget.numberStyle ??
                  Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: widget.labelStyle ??
                  Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    );
  }
}
