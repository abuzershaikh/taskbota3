// File: lib/phone_mockup/app_info_screen.dart
import 'dart:io'; // Added for File class
import 'package:flutter/material.dart';
import 'clickable_outline.dart';
import 'phone_mockup_container.dart'; // Import PhoneMockupContainer to access ValueNotifier

// Changed back to StatelessWidget
class AppInfoScreen extends StatelessWidget {
  final Map<String, String> app;
  final VoidCallback onBack;
  final void Function(Map<String, String> app) onNavigateToClearData;
  final void Function(Widget dialog) showDialog;
  final void Function() dismissDialog;

  // Keys passed from PhoneMockupContainerState
  final GlobalKey<ClickableOutlineState> backButtonKey;
  final GlobalKey<ClickableOutlineState> openButtonKey;
  final GlobalKey<ClickableOutlineState> storageCacheButtonKey;
  final GlobalKey<ClickableOutlineState> mobileDataKey;
  final GlobalKey<ClickableOutlineState> batteryKey;
  final GlobalKey<ClickableOutlineState> notificationsKey;
  final GlobalKey<ClickableOutlineState> permissionsKey;
  final GlobalKey<ClickableOutlineState> openByDefaultKey;
  final GlobalKey<ClickableOutlineState> uninstallButtonKey;

  const AppInfoScreen({
    super.key,
    required this.app,
    required this.onBack,
    required this.onNavigateToClearData,
    required this.showDialog,
    required this.dismissDialog,
    required this.backButtonKey,
    required this.openButtonKey,
    required this.storageCacheButtonKey,
    required this.mobileDataKey,
    required this.batteryKey,
    required this.notificationsKey,
    required this.permissionsKey,
    required this.openByDefaultKey,
    required this.uninstallButtonKey,
  });

  @override
  Widget build(BuildContext context) {
    // Access the caption notifier from the nearest PhoneMockupContainer ancestor
    final PhoneMockupContainerState? phoneMockupState = context.findAncestorStateOfType<PhoneMockupContainerState>();
    final ValueNotifier<String>? captionNotifier = phoneMockupState?.widget.currentCaption;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: ClickableOutline(
          key: backButtonKey,
          action: () async => onBack(),
          captionNotifier: captionNotifier, // Pass notifier
          caption: 'Tap here to go back to the previous screen.', // Conversational caption
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        title: const Text(
          'App info',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                Builder(
                  builder: (context) {
                    final String iconPath = app['icon']!;
                    Widget iconWidget;
                    if (iconPath.startsWith('assets/')) {
                      iconWidget = Image.asset(
                        iconPath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading asset in AppInfoScreen: $iconPath - $error");
                          return const Icon(Icons.broken_image, size: 80);
                        },
                      );
                    } else {
                      iconWidget = Image.file(
                        File(iconPath),
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print("Error loading file in AppInfoScreen: $iconPath - $error");
                          return const Icon(Icons.broken_image, size: 80);
                        },
                      );
                    }
                    return iconWidget;
                  }
                ),
                const SizedBox(height: 10),
                Text(
                  app['name']!,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Version ${app['version']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],
            ),
            _buildInfoCard([
              _buildInfoRow(context, openButtonKey, 'Open', '', action: () async {
                captionNotifier?.value = 'Tap "Open" to launch the app.'; // Conversational caption
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Opening ${app['name']}")),
                );
              }),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard([
              _buildInfoRow(context, storageCacheButtonKey, 'Storage & cache', app['totalSize'] ?? '0 B', action: () async {
                onNavigateToClearData(app);
              }),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, mobileDataKey, 'Mobile data & Wi-Fi', '', action: () async {
                captionNotifier?.value = 'Tap here to manage mobile data and Wi-Fi settings.'; // Conversational caption
              }),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, batteryKey, 'Battery', '', action: () async {
                captionNotifier?.value = 'Tap here to see battery usage details.'; // Conversational caption
              }),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, notificationsKey, 'Notifications', '', action: () async {
                captionNotifier?.value = 'Tap here to adjust notification settings.'; // Conversational caption
              }),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, permissionsKey, 'Permissions', '', action: () async {
                captionNotifier?.value = 'Tap here to manage app permissions.'; // Conversational caption
              }),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow(context, openByDefaultKey, 'Open by default', '', action: () async {
                captionNotifier?.value = 'Tap here to configure default app settings.'; // Conversational caption
              }),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard([
              _buildInfoRow(context, uninstallButtonKey, 'Uninstall', '', action: () async {
                captionNotifier?.value = 'Tap "Uninstall" to remove the app.'; // Conversational caption
                showDialog(
                  AlertDialog(
                    title: const Text('Uninstall App?'),
                    content: Text('Do you want to uninstall ${app['name']}?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          dismissDialog();
                          captionNotifier?.value = 'You chose to cancel uninstalling ${app['name']}.'; // Conversational caption
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          dismissDialog();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${app['name']} uninstalled!')),
                          );
                          captionNotifier?.value = '${app['name']} has been uninstalled successfully!'; // Conversational caption
                          onBack();
                        },
                        child: const Text('Uninstall'),
                      ),
                    ],
                  ),
                );
              }),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, GlobalKey<ClickableOutlineState> key, String title, String subtitle, {required Future<void> Function() action}) {
    final PhoneMockupContainerState? phoneMockupState = context.findAncestorStateOfType<PhoneMockupContainerState>();
    final ValueNotifier<String>? captionNotifier = phoneMockupState?.widget.currentCaption;
    return ClickableOutline(
      key: key,
      action: action,
      captionNotifier: captionNotifier, // Pass notifier
      caption: 'Now, tap on "$title".', // Conversational caption for row
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 14, color: Colors.blue),
                  ),
                ],
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}