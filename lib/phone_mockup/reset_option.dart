// lib/phone_mockup/reset_option.dart
import 'package:flutter/material.dart';
import 'clickable_outline.dart';

class ResetOptionScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNavigateToResetMobileNetwork;
  final void Function(BuildContext, Widget) showMockupDialog;
  final void Function(String) showMockupToast;
  final VoidCallback dismissMockupDialog;
  final GlobalKey<ClickableOutlineState>? resetMobileNetworkKey;

  const ResetOptionScreen({
    super.key,
    required this.onBack,
    required this.onNavigateToResetMobileNetwork,
    required this.showMockupDialog,
    required this.showMockupToast,
    required this.dismissMockupDialog,
    this.resetMobileNetworkKey,
  });

  @override
  State<ResetOptionScreen> createState() => ResetOptionScreenState();
}

class ResetOptionScreenState extends State<ResetOptionScreen> {
  final List<String> resetOptions = [
    'Reset Mobile Network Settings',
    'Reset Bluetooth & Wi-Fi',
    'Reset app preferences',
    'Erase all data (factory reset)',
  ];

  late Map<String, GlobalKey<ClickableOutlineState>> _optionKeys;

  @override
  void initState() {
    super.initState();
    _optionKeys = {
      for (var option in resetOptions)
        option: option == 'Reset Mobile Network Settings' && widget.resetMobileNetworkKey != null
            ? widget.resetMobileNetworkKey!
            : GlobalKey<ClickableOutlineState>()
    };
  }

  GlobalKey<ClickableOutlineState>? getResetMobileNetworkKey() {
      return _optionKeys['Reset Mobile Network Settings'];
  }

  void _showResetDialog(BuildContext context) {
    widget.showMockupDialog(
      context,
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Bluetooth & Wi-Fi'),
        content: const Text(
          "This will reset all Wi-Fi & Bluetooth settings. You can't undo this action.",
          style: TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('CANCEL', style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: widget.dismissMockupDialog,
          ),
          TextButton(
            child: Text('RESET', style: TextStyle(color: Theme.of(context).primaryColor)),
            onPressed: () {
              widget.dismissMockupDialog();
              widget.showMockupToast('Wi-Fi & Bluetooth settings have been reset.');
              print('Resetting Bluetooth & Wi-Fi settings...');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text(
          "Reset options",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.blueGrey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.separated(
          itemCount: resetOptions.length,
          separatorBuilder: (context, index) => const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.black12,
          ),
          itemBuilder: (context, index) {
            final option = resetOptions[index];
            final itemKey = _optionKeys[option]!;

            return ClickableOutline(
              key: itemKey,
              action: () async {
                if (option == 'Reset Mobile Network Settings') {
                  widget.onNavigateToResetMobileNetwork();
                } else if (option == 'Reset Bluetooth & Wi-Fi') {
                  _showResetDialog(context);
                } else {
                  print('$option tapped');
                }
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                title: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                onTap: () {
                  itemKey.currentState?.triggerOutlineAndAction();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
