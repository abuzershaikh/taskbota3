 
 
import 'dart:io'; // Added for File class
import 'package:flutter/material.dart';
import 'clickable_outline.dart'; // Added import

class CustomAppActionDialog extends StatelessWidget {
  final Map<String, String> app;
  final Function(String actionName, Map<String, String> appDetails) onActionSelected;

  // Keys for ClickableOutline
  final GlobalKey<ClickableOutlineState> appInfoKey;
  final GlobalKey<ClickableOutlineState> uninstallKey;
  // final GlobalKey<ClickableOutlineState> forceStopKey; // Force stop not in current UI

  const CustomAppActionDialog({
    super.key,
    required this.app,
    required this.onActionSelected,
    required this.appInfoKey,
    required this.uninstallKey,
    // required this.forceStopKey,
  });

  @override
  Widget build(BuildContext context) {
    const double desiredDialogWidth = 180.0;

    final String iconPath = app['icon']!;
    Widget iconWidget;

    if (iconPath.startsWith('assets/')) {
      iconWidget = Image.asset(
        iconPath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading asset in CustomAppActionDialog: $iconPath - $error");
          return const Icon(Icons.broken_image, size: 60); // Placeholder
        },
      );
    } else {
      iconWidget = Image.file(
        File(iconPath),
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          print("Error loading file in CustomAppActionDialog: $iconPath - $error");
          return const Icon(Icons.broken_image, size: 60); // Placeholder
        },
      );
    }

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: iconWidget, // Use the dynamic iconWidget here
            ),
            const SizedBox(height: 10),
            Text(
              app['name']!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: desiredDialogWidth,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogOptionWithKey(
                      key: appInfoKey,
                      icon: Icons.info_outline,
                      text: 'App info',
                      onTap: () => onActionSelected('App info', app),
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    // "Pause app" - not requested for key management
                    _buildDialogOption(Icons.pause_circle_outline, 'Pause app', () {
                      onActionSelected('Pause app', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOptionWithKey(
                      key: uninstallKey,
                      icon: Icons.delete_outline,
                      text: 'Uninstall',
                      onTap: () => onActionSelected('Uninstall', app),
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    // "Share" - not requested for key management
                    _buildDialogOption(Icons.share, 'Share', () {
                      onActionSelected('Share', app);
                    }),
                    const Divider(height: 1, color: Colors.grey),
                     // "Edit" - not requested for key management
                    _buildDialogOption(Icons.edit, 'Edit', () {
                      onActionSelected('Edit', app);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Original _buildDialogOption for items without ClickableOutline
  Widget _buildDialogOption(IconData icon, String text, VoidCallback onTap) {
    return InkWell( // Using InkWell for visual feedback, similar to ListTile
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 15),
            Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // New method for options with ClickableOutline
  Widget _buildDialogOptionWithKey({
    required GlobalKey<ClickableOutlineState> key,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ClickableOutline(
      key: key,
      action: () async => onTap(), // Ensure action is async
      child: InkWell( // Using InkWell for visual feedback and existing tap behavior
        onTap: onTap, // Keep direct tap for normal user interaction
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 15),
              Text(
                text,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}