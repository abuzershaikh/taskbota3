import 'dart:io';
import 'package:flutter/material.dart';
import 'clickable_outline.dart';
import 'phone_mockup_container.dart'; // Import PhoneMockupContainer

class CustomAppActionDialog extends StatelessWidget {
  final Map<String, String> app;
  final Function(String actionName, Map<String, String> appDetails) onActionSelected;

  final GlobalKey<ClickableOutlineState> appInfoKey;
  final GlobalKey<ClickableOutlineState> uninstallKey;

  const CustomAppActionDialog({
    super.key,
    required this.app,
    required this.onActionSelected,
    required this.appInfoKey,
    required this.uninstallKey,
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
          return const Icon(Icons.broken_image, size: 60);
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
          return const Icon(Icons.broken_image, size: 60);
        },
      );
    }

    final PhoneMockupContainerState? phoneMockupState = context.findAncestorStateOfType<PhoneMockupContainerState>();
    final ValueNotifier<String>? captionNotifier = phoneMockupState?.widget.currentCaption;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: iconWidget,
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
                      onTap: () {
                        onActionSelected('App info', app);
                        captionNotifier?.value = 'You\'ve selected "App info" for ${app['name']}.'; // Conversational caption
                      },
                      captionNotifier: captionNotifier,
                      caption: 'Tap "App info" to see details about the app.', // Conversational caption
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.pause_circle_outline, 'Pause app', () {
                      onActionSelected('Pause app', app);
                      captionNotifier?.value = 'You chose to "Pause app" for ${app['name']}.'; // Conversational caption
                    }, captionNotifier),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOptionWithKey(
                      key: uninstallKey,
                      icon: Icons.delete_outline,
                      text: 'Uninstall',
                      onTap: () {
                        onActionSelected('Uninstall', app);
                        captionNotifier?.value = 'You\'ve selected "Uninstall" for ${app['name']}.'; // Conversational caption
                      },
                      captionNotifier: captionNotifier,
                      caption: 'Tap "Uninstall" to remove the app.', // Conversational caption
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.share, 'Share', () {
                      onActionSelected('Share', app);
                      captionNotifier?.value = 'You chose to "Share" ${app['name']}.'; // Conversational caption
                    }, captionNotifier),
                    const Divider(height: 1, color: Colors.grey),
                    _buildDialogOption(Icons.edit, 'Edit', () {
                      onActionSelected('Edit', app);
                      captionNotifier?.value = 'You chose to "Edit" ${app['name']}.'; // Conversational caption
                    }, captionNotifier),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogOption(IconData icon, String text, VoidCallback onTap, ValueNotifier<String>? captionNotifier) {
    return InkWell(
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

  Widget _buildDialogOptionWithKey({
    required GlobalKey<ClickableOutlineState> key,
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    ValueNotifier<String>? captionNotifier,
    String? caption,
  }) {
    return ClickableOutline(
      key: key,
      action: () async => onTap(),
      captionNotifier: captionNotifier,
      caption: caption,
      child: InkWell(
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
      ),
    );
  }
}