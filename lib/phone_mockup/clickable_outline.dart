import 'package:flutter/material.dart';
import 'dart:async';

class ClickableOutline extends StatefulWidget {
  final Widget child;
  final Future<void> Function() action;

  const ClickableOutline({
    required GlobalKey<ClickableOutlineState> key, // Key is passed here
    required this.child,
    required this.action,
  }) : super(key: key);

  @override
  ClickableOutlineState createState() => ClickableOutlineState();
}

class ClickableOutlineState extends State<ClickableOutline> {
  OverlayEntry? _overlayEntry;
  bool _isStateMounted = false;

  @override
  void initState() {
    super.initState();
    _isStateMounted = true;
  }

  @override
  void dispose() {
    _isStateMounted = false;
    _removeOutline();
    super.dispose();
  }

  Future<void> triggerOutlineAndAction() async {
    if (!_isStateMounted) return;

    _showOutline();
    await Future.delayed(const Duration(seconds: 5));

    if (_isStateMounted) {
      _removeOutline();
      await widget.action();
    }
  }

  Future<void> triggerOutlineAndExecute(
    Future<void> Function() specificAction, {
    Duration outlineDuration = const Duration(seconds: 2),
  }) async {
    if (!_isStateMounted) return;

    _showOutline();
    await Future.delayed(outlineDuration);

    if (_isStateMounted) {
      _removeOutline();
      await specificAction();
    }
  }

  void _showOutline() {
    // Ensure previous outline is removed if any
    _removeOutline();

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy,
        width: size.width,
        height: size.height,
        child: IgnorePointer( // Makes the outline non-interactive
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 3),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOutline() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
