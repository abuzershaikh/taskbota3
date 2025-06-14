import 'package:flutter/material.dart';

import 'package:phone_ui_training/phone_mockup/clickable_outline.dart' show ClickableOutlineState, ClickableOutline; // Ensure this path is correct

class Apps1Screen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onAppManagementTap;
  final GlobalKey<ClickableOutlineState> backButtonKey; // Key for the back button
  final GlobalKey<ClickableOutlineState> appManagementKey;
  final GlobalKey<ClickableOutlineState> defaultAppsKey;
  final GlobalKey<ClickableOutlineState> disabledAppsKey;
  final GlobalKey<ClickableOutlineState> recoverSystemAppsKey;
  final GlobalKey<ClickableOutlineState> autoLaunchKey;
  final GlobalKey<ClickableOutlineState> specialAppAccessKey;
  final GlobalKey<ClickableOutlineState> appLockKey;
  final GlobalKey<ClickableOutlineState> dualAppsKey;

  const Apps1Screen({
    super.key,
    required this.onBack,
    required this.onAppManagementTap,
    required this.backButtonKey,
    required this.appManagementKey,
    required this.defaultAppsKey,
    required this.disabledAppsKey,
    required this.recoverSystemAppsKey,
    required this.autoLaunchKey,
    required this.specialAppAccessKey,
    required this.appLockKey,
    required this.dualAppsKey,
  });

  @override
  State<Apps1Screen> createState() => _Apps1ScreenState();
}

class _Apps1ScreenState extends State<Apps1Screen> {
  late final List<Map<String, dynamic>> _mainAppsSettingsItems;
  late final List<Map<String, dynamic>> _relatedAppsSettingsItems;

  @override
  void initState() {
    super.initState();
    _mainAppsSettingsItems = [
      {'title': 'App management', 'key': widget.appManagementKey},
      {'title': 'Default apps', 'key': widget.defaultAppsKey},
      {'title': 'Disabled apps', 'key': widget.disabledAppsKey},
      {'title': 'Recover system apps', 'key': widget.recoverSystemAppsKey},
      {'title': 'Auto launch', 'key': widget.autoLaunchKey},
      {'title': 'Special app access', 'key': widget.specialAppAccessKey},
    ];

    _relatedAppsSettingsItems = [
      {'title': 'App Lock', 'key': widget.appLockKey},
      {'title': 'Dual apps', 'key': widget.dualAppsKey},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("Apps", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blueGrey[50],
        elevation: 0,
        leading: ClickableOutline(
          key: widget.backButtonKey,
          action: () async => widget.onBack(),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: widget.onBack,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsCard(context, _mainAppsSettingsItems),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              "You might be looking for:",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildSettingsCard(context, _relatedAppsSettingsItems),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Map<String, dynamic>> items) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: items.map((item) {
            final itemTitle = item['title'] as String;
            final itemKey = item['key'] as GlobalKey<ClickableOutlineState>;
            onTapAction() {
              if (itemTitle == 'App management') {
                widget.onAppManagementTap();
              } else {
                print('Tapped on $itemTitle');
              }
            }

            return Column(
              children: [
                ClickableOutline(
                  key: itemKey,
                  action: () async => onTapAction(),
                  child: ListTile(
                    title: Text(
                      itemTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: onTapAction,
                  ),
                ),
                if (item != items.last)
                  const Divider(indent: 16, endIndent: 16, height: 1, color: Colors.black12),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
