// File: lib/phone_mockup/custom_clear_data_dialog.dart
import 'package:flutter/material.dart';
import 'clickable_outline.dart'; // Added import

class CustomClearDataDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmButtonText;
  final Color confirmButtonColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  // Keys for ClickableOutline
  final GlobalKey<ClickableOutlineState> cancelKey;
  final GlobalKey<ClickableOutlineState> confirmKey;

  const CustomClearDataDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmButtonText,
    this.confirmButtonColor = Colors.red, // Default to red for delete/clear
    required this.onConfirm,
    required this.onCancel,
    required this.cancelKey,
    required this.confirmKey,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        content,
        style: const TextStyle(fontSize: 14, color: Colors.black87),
        textAlign: TextAlign.center,
      ),
      actions: [
        ClickableOutline(
          key: cancelKey,
          action: () async => onCancel(),
          child: TextButton(
            onPressed: onCancel, // Keep direct tap for normal user interaction
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ),
        ClickableOutline(
          key: confirmKey,
          action: () async => onConfirm(),
          child: TextButton(
            onPressed: onConfirm, // Keep direct tap for normal user interaction
            child: Text(
              confirmButtonText,
              style: TextStyle(color: confirmButtonColor),
            ),
          ),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0.0),
      actionsPadding: const EdgeInsets.all(8.0),
    );
  }
}