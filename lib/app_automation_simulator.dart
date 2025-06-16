// lib/app_automation_simulator.dart
import 'dart:convert';
import 'dart:io';
import 'dart:math'; // Import for Random
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart'; // Import path_provider
import 'phone_mockup/phone_mockup_container.dart';
import 'phone_mockup/app_grid.dart';

class AppAutomationSimulator {
  final Random _random = Random();
  final GlobalKey<PhoneMockupContainerState> phoneMockupKey;
  final GlobalKey<AppGridState> appGridKey;
  final Stopwatch _stopwatch = Stopwatch();
  final List<Map<String, String>> _log = [];

  // To hold info for the real-time log file
  File? _logFile;
  String _appNameForLog = '';
  String _simulationStartTimeForLog = '';

  AppAutomationSimulator({
    required this.phoneMockupKey,
    required this.appGridKey,
  });

  /// Initializes the log file, creating the directory in the user's Documents folder.
  Future<void> _startLog(String appName) async {
    _appNameForLog = appName;
    _simulationStartTimeForLog = DateTime.now().toIso8601String();
    _log.clear();
    _stopwatch.reset();
    _stopwatch.start();

    // Get the user's documents directory
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final logDirectory = Directory('${documentsDirectory.path}/commandlog');

    if (!await logDirectory.exists()) {
      await logDirectory.create(recursive: true);
    }

    final now = DateTime.now();
    final formatter = DateFormat('yyyy-MM-dd_HH-mm-ss');
    final String formattedDate = formatter.format(now);
    final fileName = '${appName}_$formattedDate.json';
    _logFile = File('${logDirectory.path}/$fileName');

    // Add the initial "start" entry
    _log.add({'timestamp': '00:00', 'step': 'Simulation Start'});
    await _updateLogFile();
  }

  /// Writes the current log buffer to the file, overwriting it.
  Future<void> _updateLogFile() async {
    if (_logFile == null) return;

    final logData = {
      'appName': _appNameForLog,
      'simulationStartTime': _simulationStartTimeForLog,
      'steps': _log,
    };
    final jsonString = const JsonEncoder.withIndent('  ').convert(logData);
    await _logFile!.writeAsString(jsonString);
  }

  /// Finishes the logging process.
  Future<void> _stopLog() async {
    final elapsed = _stopwatch.elapsed;
    final timestamp =
        '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    _log.add({'timestamp': timestamp, 'step': 'Simulation Stop'});
    _stopwatch.stop();
    await _updateLogFile(); // Write the final log state
    print("Log file updated at: ${_logFile?.path}");
  }

  /// A helper function to print the current step, add realistic delays, and update the log in real-time.
  Future<void> _handleStep(String message, Future<void> Function() action) async {
    final elapsed = _stopwatch.elapsed;
    final timestamp =
        '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';
    print('$timestamp - $message');
    _log.add({'timestamp': timestamp, 'step': message});

    await _updateLogFile(); // Update the log file in real-time

    phoneMockupKey.currentState?.widget.currentCaption.value = message;
    await Future.delayed(Duration(milliseconds: _random.nextInt(1000) + 700));
    await action();
    await Future.delayed(Duration(milliseconds: _random.nextInt(1500) + 1000));
  }

  /// This is the main simulation method for the combined "clear data" and "reset network" flow.
  Future<bool> startClearDataAndResetNetworkSimulation(String appName) async {
    await _startLog(appName);

    print("Starting expanded simulation for command: '$appName clear data'");
    phoneMockupKey.currentState?.widget.currentCaption.value =
        "Let's start by clearing app data and then resetting network settings.";

    final phoneMockupState = phoneMockupKey.currentState;
    final appGridState = appGridKey.currentState;

    if (phoneMockupState == null || appGridState == null) {
      print("Error: PhoneMockupContainerState or AppGridState is null. Cannot proceed.");
      phoneMockupKey.currentState?.widget.currentCaption.value =
          "Oops! The phone mockup isn't quite ready. Please try again.";
      await _stopLog();
      return false;
    }

    // --- Part 1: Clear App Data ---
    print("--- Starting Part 1: Clear App Data for $appName ---");
    phoneMockupKey.currentState?.widget.currentCaption.value = "First, we'll clear the data for $appName.";

    await _handleStep("Step 1: Go to your app", () async {
      await appGridState.scrollToApp(appName);
    });

    final appDetails = appGridState.getAppByName(appName);
    if (appDetails == null || appDetails.isEmpty) {
      print("Error: App '$appName' not found in grid.");
      phoneMockupKey.currentState?.widget.currentCaption.value =
          "Hmm, couldn't find '$appName'. Please make sure it's installed.";
      await _stopLog();
      return false;
    }

    await _handleStep("Step 2: Now, long press on the app icon — just hold your finger on it for a second.",
        () async {
      final appOutlineKey = appGridState.getKeyForApp(appName);
      await appOutlineKey?.currentState
          ?.triggerOutlineAndAction(specificCaption: "Long pressing on '$appName' to open options.");
    });

    await _handleStep("Step 3: You’ll see a small menu pop up — tap on App info.", () async {
      await phoneMockupState.triggerDialogAppInfoAction();
    });

    await _handleStep("Step 4: Wait for the App Info screen to open up.", () async {
      await Future.delayed(Duration(milliseconds: _random.nextInt(2001) + 1000));
    });

    await _handleStep("Step 5: Now tap on Storage & cache.", () async {
      await phoneMockupState.triggerAppInfoStorageCacheAction();
    });

    await _handleStep("Step 6: Wait for a second while the storage screen loads.", () async {
      await Future.delayed(Duration(milliseconds: _random.nextInt(2001) + 1000));
    });

    await _handleStep("Step 7: Next, tap on Clear data.", () async {
      await phoneMockupState.triggerClearDataButtonAction();
    });

    await _handleStep(
        "Step 8: A confirmation will show up — just tap Delete to confirm. Done! That app’s data has been cleared successfully.",
        () async {
      await phoneMockupState.triggerDialogClearDataConfirmAction();
    });

    print("--- Part 1 Complete: Data cleared for $appName. ---");
    phoneMockupKey.currentState?.widget.currentCaption.value =
        "Great! We've successfully cleared the data for $appName.";
    await Future.delayed(const Duration(seconds: 2));

    // --- Part 2: Reset Mobile Network Settings ---
    await startResetNetworkSimulation(phoneMockupState, appGridState);
    
    await _stopLog();
    return true;
  }

  /// New simulation method specifically for resetting network settings.
  Future<bool> startResetNetworkSimulation(
      PhoneMockupContainerState phoneMockupState, AppGridState appGridState) async {
    print("--- Starting Part 2: Reset Mobile Network Settings ---");
    phoneMockupKey.currentState?.widget.currentCaption.value =
        "Now, let's move on to resetting your mobile network settings.";

    await _handleStep("Step 1: Go back to your Home Screen.", () async {
      phoneMockupState.navigateHome();
    });

    await _handleStep(
        "Step 2: Now find the Settings app. You can scroll and look for it, or use the search bar at the top if your phone has one.",
        () async {
      await appGridKey.currentState?.scrollToApp('Settings');
      await Future.delayed(Duration(milliseconds: _random.nextInt(500) + 300));
      final settingsAppKey = appGridKey.currentState?.getKeyForApp('Settings');
      final settingsAppDetails = appGridKey.currentState?.getAppByName('Settings');

      if (settingsAppKey == null || settingsAppDetails == null) {
        print("Error: Could not find key or details for 'Settings' app. Aborting action.");
        phoneMockupKey.currentState?.widget.currentCaption.value =
            "Hmm, couldn't find the Settings app. Please make sure it's available.";
        throw Exception("Settings app not found in grid");
      }

      Future<void> settingsTapAction() async {
        phoneMockupState.handleItemTap('Settings', itemDetails: settingsAppDetails);
      }

      await settingsAppKey.currentState?.triggerOutlineAndExecute(settingsTapAction,
          outlineDuration: const Duration(seconds: 2), specificCaption: "Tapping 'Settings' app.");
    });

    await _handleStep("Step 3: Once inside Settings, scroll all the way down.", () async {
      await phoneMockupState.triggerSettingsScrollToEnd();
    });

    await _handleStep("Step 4: Give it a few seconds to load everything completely.", () async {
      await Future.delayed(const Duration(seconds: 5));
    });

    await _handleStep("Step 5: Now tap on System.", () async {
      await phoneMockupState.triggerSystemSettingsAction();
    });

    await _handleStep("Step 6: Inside System, tap on Reset options.", () async {
      await phoneMockupState.triggerResetOptionsAction();
    });

    await _handleStep(
        "Step 7: Here, choose Reset Mobile Network Settings. If you not find search on search bar reset network settings.",
        () async {
      await phoneMockupState.triggerResetMobileNetworkAction();
    });

    await _handleStep("Step 8: Tap on Reset settings once.", () async {
      await phoneMockupState.triggerConfirmResetMobileNetworkAction();
    });

    await _handleStep("Step 9: And then confirm by tapping Reset settings again.", () async {
      await phoneMockupState.triggerConfirmResetMobileNetworkAction();
    });

    print("--- Part 2 Complete: Mobile network settings reset. ---");
    phoneMockupKey.currentState?.widget.currentCaption.value =
        "Great! Your mobile network settings have been reset.";
    await Future.delayed(const Duration(seconds: 3));

    await _handleStep(
        "Final Step: That’s it! Now just go back to your Home Screen — You’ve successfully cleared the app data and reset your mobile network settings. Nice job! You’re all set. and now restart your phone and then 100 percent problem solve.",
        () async {
      phoneMockupState.navigateHome();
    });

    print("All simulation actions complete.");
    phoneMockupKey.currentState?.widget.currentCaption.value =
        "You're all set! Now, simply restart your phone, and your problem should be 100% solved. Nice job!";

    return true;
  }
}