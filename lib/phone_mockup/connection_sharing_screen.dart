import 'package:flutter/material.dart';

class ConnectionSharingScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ConnectionSharingScreen({super.key, required this.onBack, required void Function(String message, {Duration duration}) showInternalToast});

  @override
  State<ConnectionSharingScreen> createState() => _ConnectionSharingScreenState();
}

class _ConnectionSharingScreenState extends State<ConnectionSharingScreen> {
  bool _aeroplaneModeEnabled = false;
  bool _quickDeviceConnectEnabled = true; // Set to true as per image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          "Connection & sharing",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blueGrey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSettingsCard(context, [
            _buildToggleItem(
              Icons.airplanemode_on, // Corrected from airplane_mode_on
              'Aeroplane mode',
              _aeroplaneModeEnabled,
              (bool value) {
                setState(() {
                  _aeroplaneModeEnabled = value;
                });
              },
            ),
            _buildTrailingIconItem(Icons.wifi_tethering, 'Personal hotspot'),
            _buildTrailingIconItem(Icons.vpn_key, 'VPN'),
            _buildTrailingIconItem(Icons.dns, 'Private DNS'),
            _buildTrailingIconItem(Icons.directions_car, 'Android Auto',
                subtitle: 'Use apps on your car display.'),
          ]),
          const SizedBox(height: 16),
          _buildSettingsCard(context, [
            _buildTrailingIconItem(Icons.screen_share, 'Screencast'),
            _buildTrailingIconItem(Icons.print, 'Print', subtitle: 'On'),
            _buildToggleItem(
              Icons.devices_other,
              'Quick device connect',
              _quickDeviceConnectEnabled,
              (bool value) {
                setState(() {
                  _quickDeviceConnectEnabled = value;
                });
              },
              subtitle: 'Discover and connect to nearby devices quickly.', // Added subtitle as per image
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(
      BuildContext context, List<Widget> items) {
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
            return Column(
              children: [
                item,
                if (item != items.last)
                  const Divider(
                    indent: 72,
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

  Widget _buildToggleItem(IconData icon, String title, bool initialValue,
      ValueChanged<bool> onChanged, {String? subtitle}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue[700]),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13), // Style adjusted as per image
            )
          : null,
      trailing: Switch(
        value: initialValue,
        onChanged: onChanged, // Use the passed onChanged callback
        activeColor: Colors.blue[700], // Dark blue color for the toggle
      ),
      onTap: () {
        // Tapping the list tile itself should also toggle the switch
        onChanged(!initialValue);
      },
    );
  }

  Widget _buildTrailingIconItem(IconData icon, String title,
      {String? subtitle}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.blue[700]),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            )
          : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        // Handle tap for navigation
      },
    );
  }
}