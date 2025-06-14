import 'dart:async';
import 'package:flutter/material.dart';

class InternalToast extends StatefulWidget {
  final String message;
  final Duration visibleDuration;
  final VoidCallback onDismissed;

  const InternalToast({
    super.key,
    required this.message,
    this.visibleDuration = const Duration(seconds: 3), // Default to 3 seconds
    required this.onDismissed,
  });

  @override
  State<InternalToast> createState() => _InternalToastState();
}

class _InternalToastState extends State<InternalToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  Timer? _visibilityTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Fade-in duration
      reverseDuration: const Duration(milliseconds: 300), // Fade-out duration
      vsync: this,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn, // Curve for fade-in
      reverseCurve: Curves.easeOut, // Curve for fade-out
    );

    // Start fade-in animation
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Fade-in completed, start timer to display the toast
        _visibilityTimer = Timer(widget.visibleDuration, () {
          // Time's up, start fade-out
          _controller.reverse();
        });
      } else if (status == AnimationStatus.dismissed) {
        // Fade-out completed, call onDismissed callback
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _visibilityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Center( // Center the toast on screen, typically at the bottom via Stack in parent
        child: Material( // Material for theming and text rendering
          type: MaterialType.transparency,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              widget.message,
              style: const TextStyle(color: Colors.white, fontSize: 14.0),
            ),
          ),
        ),
      ),
    );
  }
}
