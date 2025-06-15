// lib/phone_mockup/reset_mobile_network_settings_screen.dart
import 'package:flutter/material.dart';
import 'clickable_outline.dart';
import 'phone_mockup_container.dart'; // Import PhoneMockupContainer

class ResetMobileNetworkSettingsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final void Function(String message, {Duration duration}) showInternalToast;
  final GlobalKey<ClickableOutlineState>? resetButtonKey;

  const ResetMobileNetworkSettingsScreen({
    super.key,
    required this.onBack,
    required this.showInternalToast,
    this.resetButtonKey,
  });

  @override
  State<ResetMobileNetworkSettingsScreen> createState() =>
      ResetMobileNetworkSettingsScreenState();
}

class ResetMobileNetworkSettingsScreenState
    extends State<ResetMobileNetworkSettingsScreen> {
  bool _isConfirmationStep = false;
  late final GlobalKey<ClickableOutlineState> _buttonKey;

  @override
  void initState() {
    super.initState();
    _buttonKey = widget.resetButtonKey ?? GlobalKey<ClickableOutlineState>();
  }

  GlobalKey<ClickableOutlineState> getResetButtonKey() {
      return _buttonKey;
  }

  void _handleReset() {
    final PhoneMockupContainerState? phoneMockupState = context.findAncestorStateOfType<PhoneMockupContainerState>();
    final ValueNotifier<String>? captionNotifier = phoneMockupState?.widget.currentCaption;

    if (!_isConfirmationStep) {
      setState(() {
        _isConfirmationStep = true;
      });
      captionNotifier?.value = 'Please tap "Reset settings" to confirm this action.'; // Conversational caption
    } else {
      widget.showInternalToast(
        'Network settings have been reset',
        duration: const Duration(seconds: 2),
      );
      captionNotifier?.value = 'Perfect! Your network settings have been reset.'; // Conversational caption
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          widget.onBack();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final PhoneMockupContainerState? phoneMockupState = context.findAncestorStateOfType<PhoneMockupContainerState>();
    final ValueNotifier<String>? captionNotifier = phoneMockupState?.widget.currentCaption;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reset Mobile\nNetwork Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            if (!_isConfirmationStep)
              const Text(
                'This will reset all mobile network settings',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

            if (_isConfirmationStep)
              const Text(
                "Reset all network settings? You can't undo this action.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),

            const SizedBox(height: 32),
            Center(
              child: ClickableOutline(
                key: _buttonKey,
                action: () async {
                  _handleReset();
                },
                captionNotifier: captionNotifier,
                caption: _isConfirmationStep ? 'Go ahead and tap "Reset settings" one more time to confirm.' : 'Tap "Reset settings" to continue.', // Conversational caption
                child: ElevatedButton(
                  onPressed: () {
                    _buttonKey.currentState?.triggerOutlineAndAction();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConfirmationStep
                        ? Colors.amber[300]
                        : Colors.deepPurple[50],
                    foregroundColor: _isConfirmationStep
                        ? Colors.black87
                        : Colors.deepPurple[700],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    'Reset settings',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}