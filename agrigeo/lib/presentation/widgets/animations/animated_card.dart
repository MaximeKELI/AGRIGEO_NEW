import 'package:flutter/material.dart';
import 'fade_in_widget.dart';
import 'slide_in_widget.dart';

/// Carte avec animations et effet de survol
class AnimatedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Duration delay;
  final VoidCallback? onTap;

  const AnimatedCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.color,
    this.elevation = 2.0,
    this.borderRadius,
    this.delay = Duration.zero,
    this.onTap,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) * 2,
    ).animate(CurvedAnimation(
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
    return FadeInWidget(
      delay: widget.delay,
      child: SlideInWidget(
        delay: widget.delay,
        direction: AxisDirection.down,
        child: MouseRegion(
          onEnter: (_) {
            setState(() => _isHovered = true);
            _controller.forward();
          },
          onExit: (_) {
            setState(() => _isHovered = false);
            _controller.reverse();
          },
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedBuilder(
              animation: _elevationAnimation,
              builder: (context, child) {
                return Card(
                  margin: widget.margin ?? const EdgeInsets.all(8),
                  elevation: _elevationAnimation.value,
                  color: widget.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: widget.borderRadius ??
                        BorderRadius.circular(12),
                  ),
                  child: Container(
                    padding: widget.padding ?? const EdgeInsets.all(16),
                    child: widget.child,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

