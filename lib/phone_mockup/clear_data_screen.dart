// File: lib/phone_mockup/clear_data_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zest_autodroid/phone_mockup/custom_clear_data_dialog.dart';
import 'zest_autodroid/phone_mockup/custom_clear_data_dialog.dart';
import 'clickable_outline.dart';
import 'phone_mockup_container.dart'; // Import PhoneMockupContainer to access ValueNotifier

// Changed back to StatelessWidget
class ClearDataScreen extends StatelessWidget {
  final String appName;
  final String appVersion;
  final String appIconPath;
  final String initialTotalSize;
  final String initialAppSize;
  final String initialDataSize;
  final String initialCacheSize;
  final VoidCallback onBack;
  final VoidCallback onPerformClearData;
  final VoidCallback onPerformClearCache;
  final void Function(Widget dialog) showDialog;
  final void Function() dismissDialog;

  // Keys passed from PhoneMockupContainerState
  final GlobalKey<ClickableOutlineState> backButtonKey;
  final GlobalKey<ClickableOutlineState> clearDataButtonKey;
  final GlobalKey<ClickableOutlineState> clearCacheButtonKey;

  // Keys for the CustomClearDataDialog's buttons
  final GlobalKey<ClickableOutlineState> dialogCancelKey;
  final GlobalKey<ClickableOutlineState> dialogConfirmKey;

  const ClearDataScreen({
    super.key,
    required this.appName,
    required this.appVersion,
    required this.appIconPath,
    required this.initialTotalSize,
    required this.initialAppSize,
    required this.initialDataSize,
    required this.initialCacheSize,
    required this.onBack,
    required this.onPerformClearData,
    required this.onPerformClearCache,
    required this.showDialog,
    required this.dismissDialog,
    required this.backButtonKey,
    required this.clearDataButtonKey,
    required this.clearCacheButtonKey,
    required this.dialogCancelKey, // Pass dialog keys
    required this.dialogConfirmKey, // Pass dialog keys
  });

  @override
  Widget build(BuildContext context) {
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
          captionNotifier: captionNotifier,
          caption: 'Tapping back from Clear Data screen.',
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
        ),
        title: Text(
          appName,
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Column(
              children: [
                Builder(builder: (context) {
                  Widget iconWidget;
                  if (appIconPath.startsWith('assets/')) {
                    iconWidget = Image.asset(
                      appIconPath,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                            "Error loading asset in ClearDataScreen: $appIconPath - $error");
                        return const Icon(Icons.broken_image, size: 80);
                      },
                    );
                  } else {
                    iconWidget = Image.file(
                      File(appIconPath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print(
                            "Error loading file in ClearDataScreen: $appIconPath - $error");
                        return const Icon(Icons.broken_image, size: 80);
                      },
                    );
                  }
                  return iconWidget;
                }),
                const SizedBox(height: 10),
                Text(
                  appName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Version $appVersion',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),
              ],
            ),
            _buildInfoCard([
              _buildInfoRow('Total', initialTotalSize),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow('App size', initialAppSize),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow('User data', initialDataSize),
              const Divider(height: 0, indent: 16, endIndent: 16),
              _buildInfoRow('Cache', initialCacheSize),
            ]),
            const SizedBox(height: 20),
            _buildInfoCard([
              ClickableOutline(
                key: clearDataButtonKey, 
                action: () async {
                  showDialog(
                    CustomClearDataDialog(
                      title: 'Clear app data?',
                      content: 'This app\'s data, including files and settings, will be permanently deleted from this device.',
                      confirmButtonText: 'Delete',
                      onConfirm: () {
                        dismissDialog();
                        onPerformClearData();
                      },
                      onCancel: dismissDialog,
                      cancelKey: dialogCancelKey,
                      confirmKey: dialogConfirmKey,
                      captionNotifier: captionNotifier, // Pass notifier
                    ),
                  );
                },
                captionNotifier: captionNotifier,
                caption: 'Tapping "Clear data" button.',
                child: _buildButtonRow(Icons.delete_outline, 'Clear data', 'Delete all app data'),
              ),
              const Divider(height: 0, indent: 16, endIndent: 16),
              ClickableOutline(
                key: clearCacheButtonKey, 
                action: () async {
                  showDialog(
                    CustomClearDataDialog(
                      title: 'Clear cache?',
                      content: 'This will clear the cached data for the app.',
                      confirmButtonText: 'Clear Cache',
                      onConfirm: () {
                        dismissDialog();
                        onPerformClearCache();
                      },
                      onCancel: dismissDialog,
                      cancelKey: dialogCancelKey, // Re-using, ideally separate key
                      confirmKey: dialogConfirmKey, // Re-using, ideally separate key
                      captionNotifier: captionNotifier,
                    ),
                  );
                },
                captionNotifier: captionNotifier,
                caption: 'Tapping "Clear cache" button.',
                child: _buildButtonRow(Icons.cached, 'Clear cache', 'Delete temporary files'),
              ),
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

  Widget _buildInfoRow(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonRow(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, color: Colors.blue),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}