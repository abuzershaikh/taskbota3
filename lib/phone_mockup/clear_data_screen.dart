// File: lib/phone_mockup/clear_data_screen.dart
import 'package:flutter/material.dart';
import 'package:phone_ui_training/phone_mockup/custom_clear_data_dialog.dart';
import 'clickable_outline.dart';

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
    // print('ClearDataScreen: build method called for app: $appName');
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: ClickableOutline(
          key: backButtonKey, 
          action: () async => onBack(),
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
                Image.asset(
                  appIconPath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
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
                    // Use CustomClearDataDialog instead of AlertDialog
                    CustomClearDataDialog(
                      title: 'Clear app data?',
                      content: 'This app\'s data, including files and settings, will be permanently deleted from this device.',
                      confirmButtonText: 'Delete',
                      onConfirm: () {
                        // dismissDialog is called by CustomClearDataDialog's internal logic if using its buttons
                        // For programmatic outline call, onConfirm itself should handle dismissal if needed
                        // However, the original onConfirm for the dialog's button already calls dismissDialog.
                        // So, this onConfirm (passed to CustomClearDataDialog) will be called, which calls dismissDialog.
                        dismissDialog(); // Ensure dialog is dismissed
                        onPerformClearData();
                      },
                      onCancel: dismissDialog,
                      cancelKey: dialogCancelKey, // Pass the key
                      confirmKey: dialogConfirmKey, // Pass the key
                    ),
                  );
                },
                child: _buildButtonRow(Icons.delete_outline, 'Clear data', 'Delete all app data'),
              ),
              const Divider(height: 0, indent: 16, endIndent: 16),
              ClickableOutline(
                key: clearCacheButtonKey, 
                action: () async {
                  showDialog(
                    // Using CustomClearDataDialog for consistency, though keys aren't strictly needed for "Clear Cache" yet by AppAutomationSimulator
                    CustomClearDataDialog(
                      title: 'Clear cache?',
                      content: 'This will clear the cached data for the app.',
                      confirmButtonText: 'Clear Cache',
                      onConfirm: () {
                        dismissDialog();
                        onPerformClearCache();
                      },
                      onCancel: dismissDialog,
                      // These keys are for the dialog's own buttons.
                      // For this "Clear Cache" path, we might not have specific automation triggers for its dialog buttons yet,
                      // but passing them for consistency if CustomClearDataDialog expects them.
                      // If we had specific keys for "Clear Cache Dialog Cancel" and "Clear Cache Dialog Confirm", they'd go here.
                      // For now, using the same dialog keys as clear data, or dummy keys if they must be unique and are not used.
                      // Let's assume for now CustomClearDataDialog is flexible or we'd define separate keys if needed.
                      // For this fix, the crucial part is that CustomClearDataDialog is used for "Clear Data".
                      // Re-using keys here might lead to issues if both dialogs are somehow on screen (not possible with _activeDialog).
                      // Best practice: Pass dedicated keys if "Clear Cache" dialog buttons also need independent automation.
                      // For now, this example will reuse, assuming AppAutomationSimulator doesn't target "Clear Cache" dialog buttons.
                      cancelKey: dialogCancelKey, // Example: re-using, ideally would be e.g. _clearCacheDialogCancelKey
                      confirmKey: dialogConfirmKey, // Example: re-using, ideally would be e.g. _clearCacheDialogConfirmKey
                    ),
                  );
                },
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