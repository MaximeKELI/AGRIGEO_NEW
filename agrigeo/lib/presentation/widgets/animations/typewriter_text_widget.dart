import 'dart:async';
import 'package:flutter/material.dart';

/// Widget avec effet d'écriture progressive (typewriter)
class TypewriterTextWidget extends StatefulWidget {
  final String text;
  final Duration duration;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const TypewriterTextWidget({
    super.key,
    required this.text,
    this.duration = const Duration(milliseconds: 50),
    this.style,
    this.textAlign = TextAlign.left,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  State<TypewriterTextWidget> createState() => _TypewriterTextWidgetState();
}

class _TypewriterTextWidgetState extends State<TypewriterTextWidget> {
  String _displayText = '';
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(widget.duration, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _displayText,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }
}




