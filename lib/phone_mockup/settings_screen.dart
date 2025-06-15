// lib/phone_mockup/settings_screen.dart
import 'package:flutter/material.dart';
import 'clickable_outline.dart';
import 'phone_mockup_container.dart'; // Import PhoneMockupContainer to access ValueNotifier

class SettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final AppItemTapCallback? onSettingItemTap;
  
  const SettingsScreen({super.key, required this.onBack, this.onSettingItemTap});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  final Map<String, GlobalKey<ClickableOutlineState>> _settingsKeys = {};
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> primarySettingsData = [
    {'icon': Icons.wifi, 'title': 'Wi-Fi', 'trailing': 'Off', 'isToggle': false},
    {'icon': Icons.swap_vert, 'title': 'Mobile network', 'trailing': null},
    {'icon': Icons.bluetooth, 'title': 'Bluetooth', 'trailing': 'Off'},
    {'icon': Icons.share, 'title': 'Connection & sharing', 'trailing': null},
  ];

  final List<Map<String, dynamic>> displaySettingsData = [
    {'icon': Icons.palette_outlined, 'title': 'Wallpapers & style', 'trailing': null},
    {'icon': Icons.apps, 'title': 'Home screen & Lock screen', 'trailing': null},
    {'icon': Icons.wb_sunny_outlined, 'title': 'Display & brightness', 'trailing': null},
    {'icon': Icons.volume_up_outlined, 'title': 'Sound & vibration', 'trailing': null},
    {'icon': Icons.notifications_none, 'title': 'Notification & status bar', 'trailing': null},
  ];

  final List<Map<String, dynamic>> appSecuritySettingsData = [
    {'icon': Icons.apps, 'title': 'Apps', 'trailing': null},
    {'icon': Icons.security_outlined, 'title': 'Password & security', 'trailing': null},
  ];

  final List<Map<String, dynamic>> moreSettingsData = [
    {'icon': Icons.health_and_safety_outlined, 'title': 'Safety & emergency', 'trailing': null},
    {'icon': Icons.self_improvement_outlined, 'title': 'Digital Wellbeing & parental controls', 'trailing': null},
    {'icon': Icons.integration_instructions_outlined, 'title': 'Google', 'trailing': null},
    {'icon': Icons.system_update_alt, 'title': 'System updates', 'trailing': null},
    {'icon': Icons.rate_review_outlined, 'title': 'Rating & feedback', 'trailing': null},
    {'icon': Icons.help_outline, 'title': 'Help', 'trailing': null},
    {'icon': Icons.info_outline, 'title': 'System', 'trailing': null},
    {'icon': Icons.phone_android_outlined, 'title': 'About phone', 'trailing': null},
  ];

  @override
  void initState() {
    super.initState();
    _initializeKeysForList(primarySettingsData);
    _initializeKeysForList(displaySettingsData);
    _initializeKeysForList(appSecuritySettingsData);
    _initializeKeysForList(moreSettingsData);
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  void _initializeKeysForList(List<Map<String, dynamic>> list) {
    for (var item in list) {
      _settingsKeys[item['title'] as String] = GlobalKey<ClickableOutlineState>();
    }
  }

  GlobalKey<ClickableOutlineState>? getSettingItemKey(String title) {
    return _settingsKeys[title];
  }

  Future<void> scrollToEnd() async {
    final PhoneMockupContainerState? phoneMockupState = context.findAncestorStateOfType<PhoneMockupContainerState>();
    final ValueNotifier<String>? captionNotifier = phoneMockupState?.widget.currentCaption;

    int retries = 5;
    while (retries > 0 && !_scrollController.hasClients) {
      print("Scroll controller not attached yet, waiting... ($retries retries left)");
      captionNotifier?.value = "Waiting for Settings screen to be ready for scroll.";
      await Future.delayed(const Duration(milliseconds: 100));
      retries--;
    }

    if (!_scrollController.hasClients) {
      print("Error: ScrollController could not attach to a view. Cannot scroll.");
      captionNotifier?.value = "Error: Settings screen cannot be scrolled.";
      return;
    }
    
    captionNotifier?.value = "Scrolling to the end of Settings.";
    await _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final PhoneMockupContainerState? phoneMockupState = context.findAncestorStateOfType<PhoneMockupContainerState>();
    final ValueNotifier<String>? captionNotifier = phoneMockupState?.widget.currentCaption;

    return Material(
      color: Colors.blueGrey[50],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
            SliverAppBar(
              title: const Text(
                "Settings",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.blueGrey[50],
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: widget.onBack,
              ),
              pinned: true,
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    _buildSettingsCard(context, primarySettingsData, captionNotifier),
                    const SizedBox(height: 16),
                    _buildSettingsCard(context, displaySettingsData, captionNotifier),
                    const SizedBox(height: 16),
                    _buildSettingsCard(context, appSecuritySettingsData, captionNotifier),
                    const SizedBox(height: 16),
                    _buildSettingsCard(context, moreSettingsData, captionNotifier),
                    // Add a spacer at the end to ensure the list is always scrollable.
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, List<Map<String, dynamic>> items, ValueNotifier<String>? captionNotifier) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: items.map((item) {
            final itemTitle = item['title'] as String;
            final itemKey = _settingsKeys[itemTitle];

            String? subtitle;
            if (itemTitle == 'Safety & emergency') subtitle = 'Emergency, SOS, medical info, alerts';
            if (itemTitle == 'Digital Wellbeing & parental controls') subtitle = 'Keep track of screen time';
            if (itemTitle == 'Google') subtitle = 'Services & preferences';
            if (itemTitle == 'System updates') subtitle = 'Update to the latest software';
            if (itemTitle == 'Rating & feedback') subtitle = 'Send suggestions & rate your device';
            if (itemTitle == 'Help') subtitle = 'Use phone, fix issues';
            if (itemTitle == 'System') subtitle = 'Languages, time, backup';
            if (itemTitle == 'About phone') subtitle = '';

            return Column(
              children: [
                ClickableOutline(
                  key: itemKey!,
                  action: () async {
                    if (widget.onSettingItemTap != null) {
                      Map<String, String> stringItemDetails = {};
                      item.forEach((key, value) {
                        if (key != 'icon') {
                          stringItemDetails[key] = value.toString();
                        }
                      });
                      widget.onSettingItemTap!(itemTitle, itemDetails: stringItemDetails);
                    } else {
                      print('Tap action not configured for $itemTitle');
                    }
                  },
                  captionNotifier: captionNotifier, // Pass notifier
                  caption: 'Tapping "$itemTitle" in Settings.', // Set specific caption
                  child: ListTile(
                    dense: true,
                    horizontalTitleGap: 12.0,
                    leading: Icon(item['icon'] as IconData, color: Colors.black54, size: 24),
                    title: Text(
                      itemTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: subtitle != null
                        ? Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: Colors.grey[600]),
                          )
                        : null,
                    trailing: item['trailing'] != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['trailing'] as String,
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            ],
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    onTap: () {
                      itemKey.currentState?.triggerOutlineAndAction();
                    },
                  ),
                ),
                if (item != items.last)
                  const Divider(
                    indent: 56,
                    endIndent: 16,
                    height: 1,
                    color: Colors.black12,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}