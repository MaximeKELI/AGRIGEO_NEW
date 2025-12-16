import 'package:flutter/material.dart';
import 'fade_in_widget.dart';
import 'slide_in_widget.dart';

/// Widget pour afficher une liste avec animations décalées
class StaggeredListWidget extends StatelessWidget {
  final List<Widget> children;
  final Duration staggerDuration;
  final Duration animationDuration;
  final AxisDirection direction;

  const StaggeredListWidget({
    super.key,
    required this.children,
    this.staggerDuration = const Duration(milliseconds: 100),
    this.animationDuration = const Duration(milliseconds: 400),
    this.direction = AxisDirection.down,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        children.length,
        (index) => SlideInWidget(
          delay: staggerDuration * index,
          duration: animationDuration,
          direction: direction,
          child: FadeInWidget(
            delay: staggerDuration * index,
            duration: animationDuration,
            child: children[index],
          ),
        ),
      ),
    );
  }
}

