// custom_drag_scroll_behavior.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class CustomDragScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
