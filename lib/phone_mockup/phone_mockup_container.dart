// lib/phone_mockup/phone_mockup_container.dart
import 'dart:async'; // For Timer
import 'dart:io' show File;
import 'dart:math'; // For Random
import 'dart:ui'; // For BackdropFilter

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_grid.dart';
import 'app_info_screen.dart';
import 'app_management_screen.dart';
import 'apps1.dart';
import 'clear_data_screen.dart';
import 'clickable_outline.dart';
import 'connection_sharing_screen.dart';
import 'custom_app_action_dialog.dart';
import 'custom_clear_data_dialog.dart';
import 'notification_drawer.dart';
import 'reset_mobile_network_settings_screen.dart';
import 'reset_option.dart';
import 'settings_screen.dart';
import 'system_app_screen.dart';
import 'system_settings.dart';

// Enum to manage the current view being displayed in the phone mockup
enum CurrentScreenView {
  appGrid,
  settings,
  appInfo,
  clearData,
  connectionSharing,
  apps1,
  appManagement,
  systemApps,
  systemSettings,
  resetOptions,
  resetMobileNetworkSettings,
}

typedef AppItemTapCallback = void Function(String itemName,
    {Map<String, String>? itemDetails});

class PhoneMockupContainer extends StatefulWidget {
  final GlobalKey<AppGridState> appGridKey;
  final File? mockupWallpaperImage;
  final ValueNotifier<String> currentCaption;

  const PhoneMockupContainer({
    super.key,
    required this.appGridKey,
    this.mockupWallpaperImage,
    required this.currentCaption,
  });

  static final GlobalKey<PhoneMockupContainerState> globalKey =
      GlobalKey<PhoneMockupContainerState>();

  static void executeCommand(String command) {
    globalKey.currentState?._handleCommand(command);
  }

  @override
  State<PhoneMockupContainer> createState() => PhoneMockupContainerState();
}

class _BatteryFillClipper extends CustomClipper<Rect> {
  final double level; // 0.0 to 1.0

  _BatteryFillClipper({required this.level});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0.0, 0.0, size.width * level, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return (oldClipper as _BatteryFillClipper).level != level;
  }
}

class PhoneMockupContainerState extends State<PhoneMockupContainer> {
  final GlobalKey<NotificationDrawerState> _drawerKey =
      GlobalKey<NotificationDrawerState>();

  CurrentScreenView _currentScreenView = CurrentScreenView.appGrid;
  Map<String, String>? _currentAppDetails;
  Widget _currentAppScreenWidget = const SizedBox();

  bool _isBlurred = false;
  Widget? _activeDialog;

  String? _currentToastMessage;
  bool _isToastVisible = false;
  Duration _toastDuration = const Duration(seconds: 3);

  // --- Status Bar State ---
  Timer? _statusBarTimer;
  String _formattedTime = '';
  int _batteryLevel = 81;
  bool _isCharging = false;
  int _signalStrength = 4; // 1-4
  final Random _random = Random();

  // For battery drain simulation
  DateTime _lastBatteryUpdateTime = DateTime.now();
  final Duration _batteryDropInterval = const Duration(minutes: 3);
  int _secondsUntilNextSignalChange = 3;

  // --- Keys for automation ---
  final GlobalKey<ClickableOutlineState> _appInfoBackButtonKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoOpenButtonKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoStorageCacheButtonKey =
      GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoMobileDataKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoBatteryKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoNotificationsKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoPermissionsKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoOpenByDefaultKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appInfoUninstallButtonKey =
      GlobalKey();
  final GlobalKey<ClickableOutlineState> _clearDataBackButtonKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _clearDataClearDataButtonKey =
      GlobalKey();
  final GlobalKey<ClickableOutlineState> _clearDataClearCacheButtonKey =
      GlobalKey();
  final GlobalKey<ClickableOutlineState> _appActionDialogAppInfoKey =
      GlobalKey();
  final GlobalKey<ClickableOutlineState> _appActionDialogUninstallKey =
      GlobalKey();
  final GlobalKey<ClickableOutlineState> _clearDataDialogCancelKey =
      GlobalKey();
  final GlobalKey<ClickableOutlineState> _clearDataDialogConfirmKey =
      GlobalKey();
  final GlobalKey<ClickableOutlineState> _apps1BackButtonKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appManagementKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _defaultAppsKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _disabledAppsKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _recoverSystemAppsKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _autoLaunchKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _specialAppAccessKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _appLockKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _dualAppsKey = GlobalKey();
  final GlobalKey<SettingsScreenState> _settingsScreenKey = GlobalKey<SettingsScreenState>();
  final GlobalKey<ClickableOutlineState> _systemSettingsResetOptionsKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _resetOptionsMobileNetworkKey = GlobalKey();
  final GlobalKey<ClickableOutlineState> _resetMobileNetworkSettingsButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _updateCurrentScreenWidget();
    _setInitialStatusBarState();
    _startStatusBarTimer();
  }

  @override
  void dispose() {
    _statusBarTimer?.cancel();
    super.dispose();
  }

  void _setInitialStatusBarState() {
    _formattedTime = DateFormat('h:mm:ss a').format(DateTime.now());
    _batteryLevel = 81;
    _isCharging = false;
    _signalStrength = 4;
  }

  void _startStatusBarTimer() {
    _statusBarTimer?.cancel();
    _statusBarTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _updateStatusBar();
    });
  }

  void _updateStatusBar() {
    final now = DateTime.now();
    final newTime = DateFormat('h:mm:ss a').format(now);
    int newSignalStrength = _signalStrength;
    _secondsUntilNextSignalChange--;
    if (_secondsUntilNextSignalChange <= 0) {
      newSignalStrength = _random.nextInt(4) + 1;
      _secondsUntilNextSignalChange = _random.nextInt(3) + 2;
    }

    int newBatteryLevel = _batteryLevel;
    bool newIsCharging = _isCharging;

    if (newIsCharging) {
      if (now.difference(_lastBatteryUpdateTime).inSeconds >= 2) {
        newBatteryLevel++;
        _lastBatteryUpdateTime = now;
      }
      if (newBatteryLevel >= 100) {
        newBatteryLevel = 100;
        newIsCharging = false;
        _lastBatteryUpdateTime = now;
      }
    } else {
      if (now.difference(_lastBatteryUpdateTime) >= _batteryDropInterval) {
        newBatteryLevel--;
        _lastBatteryUpdateTime = now;
      }

      if (newBatteryLevel == 10 || newBatteryLevel == 5) {
        if (_random.nextBool()) {
          newIsCharging = true;
          _lastBatteryUpdateTime = now;
        }
      }

      if (newBatteryLevel < 0) newBatteryLevel = 0;
    }

    if (newTime != _formattedTime ||
        newBatteryLevel != _batteryLevel ||
        newIsCharging != _isCharging ||
        newSignalStrength != _signalStrength) {
      setState(() {
        _formattedTime = newTime;
        _batteryLevel = newBatteryLevel;
        _isCharging = newIsCharging;
        _signalStrength = newSignalStrength;
      });
    }
  }

  IconData _getSignalIcon() {
    switch (_signalStrength) {
      case 1:
        return Icons.signal_cellular_alt_1_bar;
      case 2:
        return Icons.signal_cellular_alt_2_bar;
      case 3:
        return Icons.signal_cellular_alt;
      case 4:
      default:
        return Icons.signal_cellular_4_bar;
    }
  }

  Widget _getBatteryWidget() {
    if (_isCharging) {
      return Row(
        children: [
          Text("$_batteryLevel%",
              style: const TextStyle(color: Colors.greenAccent, fontSize: 12)),
          const SizedBox(width: 4),
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(Icons.battery_full, color: Colors.grey.shade700, size: 18.0),
              ClipRect(
                clipper: _BatteryFillClipper(level: _batteryLevel / 100.0),
                child: const Icon(Icons.battery_full, color: Colors.greenAccent, size: 18.0),
              ),
            ],
          ),
        ],
      );
    } else {
      IconData batteryIcon;
      Color batteryColor = Colors.white;

      if (_batteryLevel > 95) {
        batteryIcon = Icons.battery_full;
      } else if (_batteryLevel > 80) {
        batteryIcon = Icons.battery_6_bar;
      } else if (_batteryLevel > 65) {
        batteryIcon = Icons.battery_5_bar;
      } else if (_batteryLevel > 50) {
        batteryIcon = Icons.battery_4_bar;
      } else if (_batteryLevel > 35) {
        batteryIcon = Icons.battery_3_bar;
      } else if (_batteryLevel > 20) {
        batteryIcon = Icons.battery_2_bar;
      } else if (_batteryLevel > 10) {
        batteryIcon = Icons.battery_1_bar;
      } else {
        batteryIcon = Icons.battery_alert;
        batteryColor = Colors.red;
      }

      return Row(
        children: [
          Text("$_batteryLevel%",
              style: TextStyle(color: batteryColor, fontSize: 12)),
          const SizedBox(width: 4),
          Icon(batteryIcon, color: batteryColor, size: 18),
        ],
      );
    }
  }

  Widget _buildStatusBar() {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formattedTime,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Row(
            children: [
              Icon(_getSignalIcon(), color: Colors.white, size: 18),
              const SizedBox(width: 4),
              const Icon(Icons.wifi, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              _getBatteryWidget(),
            ],
          ),
        ],
      ),
    );
  }
  
  void dismissDialog() {
    setState(() {
      _activeDialog = null;
      _isBlurred = false;
    });
  }

  void showSettingsScreen() {
    setState(() {
      _currentScreenView = CurrentScreenView.settings;
      _currentAppDetails = null;
      _updateCurrentScreenWidget();
      widget.currentCaption.value = 'Alright, let\'s head over to the Settings screen now.';
    });
  }

  void showSystemAppsScreen() {
    setState(() {
      _currentScreenView = CurrentScreenView.systemApps;
      _updateCurrentScreenWidget();
      widget.currentCaption.value = 'We\'re now on the System Apps screen.';
    });
  }

  void showInternalToast(String message,
      {Duration duration = const Duration(seconds: 3)}) {
    if (_isToastVisible) {
      setState(() => _isToastVisible = false);
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) {
          setState(() {
            _currentToastMessage = message;
            _toastDuration = duration;
            _isToastVisible = true;
          });
        }
      });
    } else {
      if (mounted) {
        setState(() {
          _currentToastMessage = message;
          _toastDuration = duration;
          _isToastVisible = true;
        });
      }
    }
  }

  void handleItemTap(String itemName, {Map<String, String>? itemDetails}) {
    print('PhoneMockupContainer: Item tapped: $itemName');
    widget.currentCaption.value = 'Tapping on "$itemName" now.';
    if (itemName == 'Settings') {
      setState(() {
        _currentScreenView = CurrentScreenView.settings;
        _currentAppDetails = null;
        _updateCurrentScreenWidget();
      });
    } else if (_currentScreenView == CurrentScreenView.settings) {
      if (itemName == 'Apps') {
        setState(() {
          _currentScreenView = CurrentScreenView.apps1;
          _updateCurrentScreenWidget();
        });
      } else if (itemName == 'Connection & sharing') {
        setState(() {
          _currentScreenView = CurrentScreenView.connectionSharing;
          _updateCurrentScreenWidget();
        });
      } else if (itemName == 'System') {
        setState(() {
          _currentScreenView = CurrentScreenView.systemSettings;
          _updateCurrentScreenWidget();
        });
      } else {
        print('Settings item tapped: $itemName');
      }
    } else if (itemDetails != null) {
      navigateToAppInfo(appDetails: Map<String, String>.from(itemDetails));
    } else {
      final appDetails = widget.appGridKey.currentState?.getAppByName(itemName);
      if (appDetails != null && appDetails.isNotEmpty) {
        navigateToAppInfo(appDetails: Map<String, String>.from(appDetails));
      } else {
        print(
            "PhoneMockupContainer: Item '$itemName' details not found for tap.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Item '$itemName' details not found.")),
          );
        }
      }
    }
  }

  @override
  void didUpdateWidget(PhoneMockupContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mockupWallpaperImage != oldWidget.mockupWallpaperImage &&
        _currentScreenView == CurrentScreenView.appGrid) {
      setState(() {
        _updateCurrentScreenWidget();
      });
    }
  }

  void _updateCurrentScreenWidget() {
    switch (_currentScreenView) {
      case CurrentScreenView.appGrid:
        _currentAppScreenWidget = AppGrid(
          key: widget.appGridKey,
          phoneMockupKey: widget.key as GlobalKey<PhoneMockupContainerState>,
          wallpaperImage: widget.mockupWallpaperImage,
          onAppTap: handleItemTap,
        );
        break;
      case CurrentScreenView.settings:
        _currentAppScreenWidget = SettingsScreen(
          key: _settingsScreenKey,
          onBack: () => navigateHome(),
          onSettingItemTap: handleItemTap,
        );
        break;
      case CurrentScreenView.appInfo:
        if (_currentAppDetails != null) {
          _currentAppScreenWidget = AppInfoScreen(
            app: _currentAppDetails!,
            onBack: () {
              widget.currentCaption.value = 'Going back to the previous screen.';
              navigateHome();
            },
            onNavigateToClearData: (appData) {
              widget.currentCaption.value = 'Navigating to Storage & cache for ${appData['name']}.';
              navigateToStorageUsage();
            },
            showDialog: (Widget dialogWidget) => _showDialog(context, dialogWidget),
            dismissDialog: dismissDialog,
            backButtonKey: _appInfoBackButtonKey,
            openButtonKey: _appInfoOpenButtonKey,
            storageCacheButtonKey: _appInfoStorageCacheButtonKey,
            mobileDataKey: _appInfoMobileDataKey,
            batteryKey: _appInfoBatteryKey,
            notificationsKey: _appInfoNotificationsKey,
            permissionsKey: _appInfoPermissionsKey,
            openByDefaultKey: _appInfoOpenByDefaultKey,
            uninstallButtonKey: _appInfoUninstallButtonKey,
          );
        } else {
          navigateHome();
        }
        break;
      case CurrentScreenView.clearData:
        if (_currentAppDetails != null) {
          _currentAppScreenWidget = ClearDataScreen(
            appName: _currentAppDetails!['name']!,
            appVersion: _currentAppDetails!['version'] ?? 'N/A',
            appIconPath: _currentAppDetails!['icon']!,
            initialTotalSize: _currentAppDetails!['totalSize'] ?? '0 B',
            initialAppSize: _currentAppDetails!['appSize'] ?? '0 B',
            initialDataSize: _currentAppDetails!['dataSize'] ?? '0 B',
            initialCacheSize: _currentAppDetails!['cacheSize'] ?? '0 B',
            onBack: () {
              widget.currentCaption.value = 'Going back from the Clear Data screen.';
              setState(() {
                _currentScreenView = CurrentScreenView.appInfo;
                _updateCurrentScreenWidget();
              });
            },
            showDialog: (Widget dialogWidget) => _showDialog(context, dialogWidget),
            dismissDialog: dismissDialog,
            onPerformClearData: () {
              _performActualDataClear(_currentAppDetails!['name']!);
              widget.currentCaption.value = 'Confirming to clear all data for ${_currentAppDetails!['name']}.';
            },
            onPerformClearCache: () {
              _performActualCacheClear(_currentAppDetails!['name']!);
              widget.currentCaption.value = 'Clearing cache for ${_currentAppDetails!['name']}.';
            },
            backButtonKey: _clearDataBackButtonKey,
            clearDataButtonKey: _clearDataClearDataButtonKey,
            clearCacheButtonKey: _clearDataClearCacheButtonKey,
            dialogCancelKey: _clearDataDialogCancelKey,
            dialogConfirmKey: _clearDataDialogConfirmKey,
          );
        } else {
          navigateHome();
        }
        break;
      case CurrentScreenView.connectionSharing:
        _currentAppScreenWidget = ConnectionSharingScreen(
          onBack: () {
            widget.currentCaption.value = 'Going back from Connection & sharing.';
            setState(() {
              _currentScreenView = CurrentScreenView.settings;
              _updateCurrentScreenWidget();
            });
          },
          showInternalToast: showInternalToast, 
        );
        break;
      case CurrentScreenView.apps1:
        _currentAppScreenWidget = Apps1Screen(
          onBack: () {
            widget.currentCaption.value = 'Going back from the Apps section.';
            setState(() {
              _currentScreenView = CurrentScreenView.settings;
              _updateCurrentScreenWidget();
            });
          },
          onAppManagementTap: () {
            widget.currentCaption.value = 'Tapping on App management now.';
            setState(() {
              _currentScreenView = CurrentScreenView.appManagement;
              _updateCurrentScreenWidget();
            });
          },
          backButtonKey: _apps1BackButtonKey,
          appManagementKey: _appManagementKey,
          defaultAppsKey: _defaultAppsKey,
          disabledAppsKey: _disabledAppsKey,
          recoverSystemAppsKey: _recoverSystemAppsKey,
          autoLaunchKey: _autoLaunchKey,
          specialAppAccessKey: _specialAppAccessKey,
          appLockKey: _appLockKey,
          dualAppsKey: _dualAppsKey,
        );
        break;
      case CurrentScreenView.appManagement:
        _currentAppScreenWidget = AppManagementScreen(
            onBack: () {
              widget.currentCaption.value = 'Returning from App Management.';
              setState(() {
                _currentScreenView = CurrentScreenView.apps1;
                _updateCurrentScreenWidget();
              });
            },
            onNavigateToSystemApps: showSystemAppsScreen, onAppSelected: (Map<String, String> app) => navigateToAppInfo(appDetails: app),);
        break;
      case CurrentScreenView.systemApps:
        _currentAppScreenWidget = SystemAppScreen(
          onBack: () {
            widget.currentCaption.value = 'Going back from System Apps.';
            setState(() {
              _currentScreenView = CurrentScreenView.appManagement;
              _updateCurrentScreenWidget();
            });
          }, onAppSelected: (Map<String, String> app) => navigateToAppInfo(appDetails: app),
        );
        break;
      case CurrentScreenView.systemSettings:
        _currentAppScreenWidget = SystemSettingsScreen(
          onBack: () {
            widget.currentCaption.value = 'Returning from System settings.';
            setState(() {
              _currentScreenView = CurrentScreenView.settings;
              _updateCurrentScreenWidget();
            });
          },
          onNavigateToResetOptions: () {
            widget.currentCaption.value = 'Navigating to Reset options.';
            setState(() {
              _currentScreenView = CurrentScreenView.resetOptions;
              _updateCurrentScreenWidget();
            });
          },
          resetOptionsKey: _systemSettingsResetOptionsKey,
        );
        break;
      case CurrentScreenView.resetOptions:
        _currentAppScreenWidget = ResetOptionScreen(
          onBack: () {
            widget.currentCaption.value = 'Going back from Reset options.';
            setState(() {
              _currentScreenView = CurrentScreenView.systemSettings;
              _updateCurrentScreenWidget();
            });
          },
          onNavigateToResetMobileNetwork: () {
            widget.currentCaption.value = 'Choosing to Reset Mobile Network Settings.';
            setState(() {
              _currentScreenView = CurrentScreenView.resetMobileNetworkSettings;
              _updateCurrentScreenWidget();
            });
          },
          showMockupDialog: _showDialog,
          showMockupToast: showInternalToast,
          dismissMockupDialog: dismissDialog,
          resetMobileNetworkKey: _resetOptionsMobileNetworkKey,
        );
        break;
      case CurrentScreenView.resetMobileNetworkSettings:
        _currentAppScreenWidget = ResetMobileNetworkSettingsScreen(
          onBack: () {
            widget.currentCaption.value = 'Returning from Reset Mobile Network Settings.';
            setState(() {
              _currentScreenView = CurrentScreenView.resetOptions;
              _updateCurrentScreenWidget();
            });
          },
          showInternalToast: showInternalToast,
          resetButtonKey: _resetMobileNetworkSettingsButtonKey,
        );
        break;
    }
  }

  Future<void> _handleCommand(String command) async {
    final cmd = command.toLowerCase().trim();
    if (cmd.contains('settings')) {
      _handleAppTap('Settings');
    } else if (cmd.startsWith('long press ')) {
      final appName = cmd.substring('long press '.length).trim();
      final appDetails = widget.appGridKey.currentState?.getAppByName(appName);
      if (appDetails != null && appDetails.isNotEmpty) {
        handleAppLongPress(appDetails);
        widget.currentCaption.value = 'Long pressing on "$appName".';
      } else {
        print(
            'PhoneMockupContainer: App for programmatic long press "$appName" not found.');
      }
    } else if (cmd.startsWith('tap ')) {
      final appName = cmd.substring('tap '.length).trim();
      _handleAppTap(appName);
      widget.currentCaption.value = 'Tapping on "$appName" now.';
    } else if (cmd.contains('back')) {
      widget.currentCaption.value = 'Tapping the back button.';
      if (_currentScreenView == CurrentScreenView.appInfo) {
        await triggerAppInfoBackButtonAction();
      } else if (_currentScreenView == CurrentScreenView.clearData) {
        await triggerClearDataBackButtonAction();
      } else if (_currentScreenView == CurrentScreenView.connectionSharing ||
          _currentScreenView == CurrentScreenView.apps1 ||
          _currentScreenView == CurrentScreenView.systemSettings) {
        setState(() {
          _currentScreenView = CurrentScreenView.settings;
          _updateCurrentScreenWidget();
        });
      } else if (_currentScreenView == CurrentScreenView.appManagement) {
        setState(() {
          _currentScreenView = CurrentScreenView.apps1;
          _updateCurrentScreenWidget();
        });
      } else if (_currentScreenView == CurrentScreenView.systemApps) {
        setState(() {
          _currentScreenView = CurrentScreenView.appManagement;
          _updateCurrentScreenWidget();
        });
       } else if (_currentScreenView == CurrentScreenView.resetOptions) {
          setState(() {
            _currentScreenView = CurrentScreenView.systemSettings;
            _updateCurrentScreenWidget();
          });
        } else if (_currentScreenView == CurrentScreenView.resetMobileNetworkSettings) {
          setState(() {
            _currentScreenView = CurrentScreenView.resetOptions;
            _updateCurrentScreenWidget();
          });
      } else if (_currentScreenView == CurrentScreenView.settings) {
        navigateHome();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Already on main screen or no back action defined')),
          );
        }
      }
    } else if (cmd.contains('notification')) {
      _openNotificationDrawer();
      widget.currentCaption.value = 'Opening the notification drawer.';
    } else if (cmd.startsWith('scroll to')) {
      final appName = cmd.substring('scroll to'.length).trim();
      if (widget.appGridKey.currentState != null) {
        widget.currentCaption.value = 'Scrolling to find "$appName".';
        widget.appGridKey.currentState?.scrollToApp(appName);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('AppGrid not ready to scroll.')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unknown command: $command')),
        );
      }
    }
  }

  void _handleAppTap(String appName) {
    handleItemTap(appName);
  }

  void handleAppLongPress(Map<String, String> app) {
    _currentAppDetails = Map<String, String>.from(app);
    _showCustomAppActionDialog(_currentAppDetails!);
  }

  void _showCustomAppActionDialog(Map<String, String> appDetails) {
    setState(() {
      _isBlurred = true;
      _activeDialog = CustomAppActionDialog(
        app: appDetails,
        onActionSelected: (actionName, appDetailsFromDialog) {
          dismissDialog();
          if (actionName == 'App info') {
            widget.currentCaption.value = 'You\'ve selected "App info" for ${appDetailsFromDialog['name']}.';
            navigateToAppInfo(appDetails: appDetailsFromDialog);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        "$actionName for ${appDetailsFromDialog['name'] ?? 'unknown app'}")),
              );
            }
          }
        },
        appInfoKey: _appActionDialogAppInfoKey,
        uninstallKey: _appActionDialogUninstallKey,
      );
    });
  }

  void navigateToAppInfo({Map<String, String>? appDetails}) {
    final detailsToUse = appDetails ?? _currentAppDetails;
    if (detailsToUse != null) {
      if (_currentAppDetails != detailsToUse) {
        _currentAppDetails = detailsToUse;
      }
      setState(() {
        _currentScreenView = CurrentScreenView.appInfo;
        _updateCurrentScreenWidget();
      });
    } else {
      print(
          "PhoneMockupContainer: Error - AppDetails is null for navigateToAppInfo.");
    }
  }

  void navigateToStorageUsage() {
    if (_currentScreenView == CurrentScreenView.appInfo &&
        _currentAppDetails != null) {
      setState(() {
        _currentScreenView = CurrentScreenView.clearData;
        _updateCurrentScreenWidget();
      });
    } else {
      print(
          "PhoneMockupContainer: Error - Not on AppInfo or _currentAppDetails is null for navigateToStorageUsage.");
    }
  }

  Future<void> _performActualDataClear(String appName) async {
    await widget.appGridKey.currentState?.updateAppDataSize(
        appName, '0 B', _currentAppDetails?['cacheSize'] ?? '0 B');
    if (_currentAppDetails != null && _currentAppDetails!['name'] == appName) {
      setState(() {
        _currentAppDetails!['dataSize'] = '0 B';
        double appSizeMB = double.tryParse(
                _currentAppDetails!['appSize']!.replaceAll(' MB', '')) ??
            0;
        double cacheSizeMB = double.tryParse(
                _currentAppDetails!['cacheSize']!.replaceAll(' MB', '')) ??
            0;
        _currentAppDetails!['totalSize'] =
            '${(appSizeMB + cacheSizeMB).toStringAsFixed(1)} MB';
        if (_currentScreenView == CurrentScreenView.clearData) {
          _updateCurrentScreenWidget();
        }
      });
    }
    if (mounted) {
      showInternalToast('Data cleared for $appName');
    }
  }

  Future<void> _performActualCacheClear(String appName) async {
    await widget.appGridKey.currentState?.updateAppDataSize(
        appName, _currentAppDetails?['dataSize'] ?? '0 B', '0 B');

    if (_currentAppDetails != null && _currentAppDetails!['name'] == appName) {
      setState(() {
        _currentAppDetails!['cacheSize'] = '0 B';
        double appSizeMB = double.tryParse(
                _currentAppDetails!['appSize']!.replaceAll(' MB', '')) ??
            0;
        double dataSizeMB = double.tryParse(
                _currentAppDetails!['dataSize']!.replaceAll(' MB', '')) ??
            0;
        _currentAppDetails!['totalSize'] =
            '${(appSizeMB + dataSizeMB).toStringAsFixed(1)} MB';
        if (_currentScreenView == CurrentScreenView.clearData) {
          _updateCurrentScreenWidget();
        }
      });
    }
    if (mounted) {
      showInternalToast('Cache cleared for $appName');
    }
  }

  Future<void> triggerAppInfoStorageCacheAction() async {
    widget.currentCaption.value = 'Now, tap on "Storage & cache".';
    return await _appInfoStorageCacheButtonKey.currentState?.triggerOutlineAndAction();
  }
  Future<void> triggerAppInfoBackButtonAction() async {
    widget.currentCaption.value = 'Tapping the "Back" button from App Info.';
    return await _appInfoBackButtonKey.currentState?.triggerOutlineAndAction();
  }
  Future<void> triggerClearDataButtonAction() async {
    widget.currentCaption.value = 'Now, tap on "Clear data".';
    return await _clearDataClearDataButtonKey.currentState?.triggerOutlineAndAction();
  }
  Future<void> triggerClearCacheButtonAction() async {
    widget.currentCaption.value = 'Now, tap on "Clear cache".';
    return await _clearDataClearCacheButtonKey.currentState?.triggerOutlineAndAction();
  }
  Future<void> triggerClearDataBackButtonAction() async {
    widget.currentCaption.value = 'Tapping the "Back" button from Clear Data.';
    return await _clearDataBackButtonKey.currentState?.triggerOutlineAndAction();
  }
  Future<void> triggerDialogAppInfoAction() async {
    widget.currentCaption.value = 'Please tap on "App info" in the dialog.';
    return await _appActionDialogAppInfoKey.currentState?.triggerOutlineAndAction();
  }
  Future<void> triggerDialogUninstallAction() async {
    widget.currentCaption.value = 'Please tap on "Uninstall" in the dialog.';
    return await _appActionDialogUninstallKey.currentState?.triggerOutlineAndAction();
  }
  Future<void> triggerDialogClearDataConfirmAction() async {
    widget.currentCaption.value = 'Now, tap "Delete" to confirm.';
    return await _clearDataDialogConfirmKey.currentState?.triggerOutlineAndAction();
  }
  Future<void> triggerDialogClearDataCancelAction() async {
    widget.currentCaption.value = 'Tapping "Cancel" to stop the clear data operation.';
    return await _clearDataDialogCancelKey.currentState?.triggerOutlineAndAction();
  }
      
  Future<void> triggerSystemSettingsAction() async {
    final settingsState = _settingsScreenKey.currentState;
    if (settingsState != null) {
        final systemItemKey = settingsState.getSettingItemKey('System');
        if (systemItemKey != null) {
          widget.currentCaption.value = 'Now, tap on "System" in Settings.';
          await systemItemKey.currentState?.triggerOutlineAndAction();
        } else {
          print("Error: System settings item key not found.");
        }
    } else {
        print("Error: SettingsScreen state not found.");
    }
  }

  Future<void> triggerResetOptionsAction() async {
    widget.currentCaption.value = 'Next, tap on "Reset options" in System settings.';
    return await _systemSettingsResetOptionsKey.currentState?.triggerOutlineAndAction();
  }
  
  Future<void> triggerResetMobileNetworkAction() async {
    widget.currentCaption.value = 'Now, choose "Reset Mobile Network Settings".';
    return await _resetOptionsMobileNetworkKey.currentState?.triggerOutlineAndAction();
  }

  Future<void> triggerConfirmResetMobileNetworkAction() async {
    widget.currentCaption.value = 'Tap "Reset settings" to confirm.';
    return await _resetMobileNetworkSettingsButtonKey.currentState?.triggerOutlineAndAction();
  }

  void simulateClearDataClick() {
    if (_currentAppDetails != null) {
      final String appName = _currentAppDetails!['name']!;
      widget.currentCaption.value = 'Opening the confirmation dialog to clear data for "$appName".';
      _showDialog(
        context,
        CustomClearDataDialog(
          title: 'Clear app data?',
          content:
              'This app\'s data, including files and settings, will be permanently deleted from this device.',
          confirmButtonText: 'Delete',
          onConfirm: () {
            dismissDialog();
            _performActualDataClear(appName);
          },
          onCancel: dismissDialog,
          cancelKey: _clearDataDialogCancelKey,
          confirmKey: _clearDataDialogConfirmKey,
        ),
      );
    } else {
      print(
          "PhoneMockupContainer: Error - No app selected for simulateClearDataClick.");
    }
  }

  void simulateConfirmDelete() {
    if (_activeDialog != null && _currentAppDetails != null) {
      triggerDialogClearDataConfirmAction();
    } else {
      print(
          "PhoneMockupContainer: Error - No active dialog or no app details for simulateConfirmDelete.");
    }
  }

  void navigateHome() {
    setState(() {
      _currentScreenView = CurrentScreenView.appGrid;
      _currentAppDetails = null;
      dismissDialog();
      _updateCurrentScreenWidget();
      widget.currentCaption.value = 'Returning to the Home screen.';
    });
  }

  void _openNotificationDrawer() {
    _drawerKey.currentState?.openDrawer();
  }

  double get currentNotificationDrawerHeight {
    return _drawerKey.currentState?.currentDrawerHeight ?? 0.0;
  }

  void _showDialog(BuildContext context, Widget dialogContent) {
    setState(() {
      _activeDialog = dialogContent;
      _isBlurred = true;
      widget.currentCaption.value = 'A new dialog has appeared on screen.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 600,
        decoration: const BoxDecoration(
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(0.0),
          child: Stack(
            children: [
              Positioned(
                top: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: _openNotificationDrawer,
                child: _buildStatusBar(),
              ),
            ),
            const Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Divider(
                height: 1,
                color: Colors.white30,
              ),
            ),
            Positioned.fill(
              top: 31,
              child: Material(
                type: MaterialType.transparency,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: KeyedSubtree(
                    key: ValueKey<CurrentScreenView>(_currentScreenView),
                    child: _currentAppScreenWidget,
                  ),
                ),
              ),
            ),
            if (_isBlurred)
              Positioned.fill(
                top: 31,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Container(color: Colors.black.withOpacity(0.0)),
                ),
              ),
            if (_activeDialog != null)
              Positioned.fill(
                top: 31,
                child: GestureDetector(
                  onTap: dismissDialog,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: GestureDetector(
                        onTap:
                            () {},
                        child: _activeDialog!,
                      ),
                    ),
                  ),
                ),
              ),
            NotificationDrawer(key: _drawerKey),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> triggerSettingsScrollToEnd() async {
  final settingsState = _settingsScreenKey.currentState;
  if (settingsState != null) {
    widget.currentCaption.value = 'Now, please scroll all the way down in Settings.';
    await settingsState.scrollToEnd();
  } else {
    print("Error: SettingsScreen state not found, cannot scroll to end.");
  }
}
}
