// lib/phone_mockup/app_grid.dart
import 'package:flutter/material.dart';
import 'dart:io'; // Import for File
import 'dart:math'; // Import for Random
import 'dart:async'; // Import for Future
import 'dart:convert'; // for json.decode
import 'package:flutter/services.dart' show rootBundle; // for rootBundle
import 'clickable_outline.dart'; // Import the new widget
import 'phone_mockup_container.dart'; // Required for actions, and AppItemTapCallback

class AppGrid extends StatefulWidget {
  final GlobalKey<PhoneMockupContainerState> phoneMockupKey;
  final File? wallpaperImage; // Added wallpaper image parameter
  final AppItemTapCallback? onAppTap;

  const AppGrid({
    super.key,
    required this.phoneMockupKey,
    this.wallpaperImage, // Added to constructor
    this.onAppTap,
  });

  @override
  State<AppGrid> createState() => AppGridState();
}

class AppGridState extends State<AppGrid> {
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();
  List<Map<String, String>> _apps = [];
  Map<String, GlobalKey<ClickableOutlineState>> appItemKeys = {};

  @override
  void initState() {
    super.initState();
    _apps = _generateRandomAppSizes(_initialApps);
    for (var app in _apps) {
      final appName = app['name'];
      if (appName != null) {
        appItemKeys[appName] = GlobalKey<ClickableOutlineState>();
      }
    }
    _loadIconsFromAssets(); // Call the new method
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _generateRandomAppSize() {
    final random = Random();
    final units = ['KB', 'MB', 'GB'];
    String unit = units[random.nextInt(units.length)];
    double size;

    if (unit == 'KB') {
      size = (random.nextInt(900) + 100).toDouble(); // 100-999 KB
      return '${size.toInt()} KB';
    } else if (unit == 'MB') {
      size = random.nextDouble() * 500 + 1; // 1.0 - 500.9 MB
      if (random.nextBool()) { // Occasionally make it a whole number
          return '${size.toInt()} MB';
      }
      return '${size.toStringAsFixed(1)} MB';
    } else { // GB
      size = random.nextDouble() * 5 + 0.5; // 0.5 - 5.4 GB
      return '${size.toStringAsFixed(1)} GB';
    }
  }

  Future<void> _loadIconsFromAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final List<Map<String, String>> newlyFoundIcons = [];
      final existingIconPaths = _initialApps.map((app) => app['icon']).toSet();

      for (var key in manifestMap.keys) {
        if (key.startsWith('assets/icons/') && !existingIconPaths.contains(key)) {
          String namePart = key.substring('assets/icons/'.length);
          final dotIndex = namePart.lastIndexOf('.');
          if (dotIndex != -1) {
            namePart = namePart.substring(0, dotIndex);
          }
          newlyFoundIcons.add({'name': namePart, 'icon': key});
        }
      }

      if (newlyFoundIcons.isNotEmpty) {
        final currentAppNames = _apps.map((app) => app['name']).toSet();
        final trulyNewIcons = newlyFoundIcons.where((icon) => !currentAppNames.contains(icon['name'])).toList();

        if (trulyNewIcons.isNotEmpty) {
          addIcons(trulyNewIcons);
        }
      }
    } catch (e) {
      print('Error loading icons from assets: $e');
    }
  }

  void addIcons(List<Map<String, String>> newIcons) {
    setState(() {
      for (var iconData in newIcons) {
        if (iconData['name'] == null || iconData['icon'] == null) {
          print("Skipping icon due to missing name or icon path: $iconData");
          continue;
        }

        final double appSizeMB = _random.nextDouble() * (200 - 50) + 50;
        final double dataSizeMB = _random.nextDouble() * (100 - 10) + 10;
        final double cacheSizeMB = _random.nextDouble() * (50 - 5) + 5;
        final double totalSizeMB = appSizeMB + dataSizeMB + cacheSizeMB;

        iconData['appSize'] = '${appSizeMB.toStringAsFixed(1)} MB';
        iconData['dataSize'] = '${dataSizeMB.toStringAsFixed(1)} MB';
        iconData['cacheSize'] = '${cacheSizeMB.toStringAsFixed(1)} MB';
        iconData['totalSize'] = '${totalSizeMB.toStringAsFixed(1)} MB';
        
        if (iconData['version'] == null) {
          iconData['version'] = '1.0.0';
        }

        _apps.add(iconData);
        appItemKeys[iconData['name']!] = GlobalKey<ClickableOutlineState>();
      }
    });
  }

  Map<String, String>? getAppByName(String appName) {
    try {
      return _apps.firstWhere((app) => app['name'] == appName);
    } catch (e) {
      return null;
    }
  }

  List<Map<String, String>> getAllApps() {
    return _apps;
  }
  
  GlobalKey<ClickableOutlineState>? getKeyForApp(String appName) {
    return appItemKeys[appName];
  }

  Future<void> updateAppDataSize(String appName, String newDataSize, String newCacheSize) async {
    final index = _apps.indexWhere((app) => app['name'] == appName);
    if (index != -1) {
      setState(() {
        final currentApp = _apps[index];
        final double currentAppSize = double.tryParse(currentApp['appSize']?.replaceAll(' MB', '') ?? '0') ?? 0;
        final double updatedDataSize = double.tryParse(newDataSize.replaceAll(' MB', '')) ?? 0;
        final double updatedCacheSize = double.tryParse(newCacheSize.replaceAll(' MB', '')) ?? 0;
        final double newTotalSize = currentAppSize + updatedDataSize + updatedCacheSize;

        _apps[index] = {
          ...currentApp,
          'dataSize': newDataSize,
          'cacheSize': newCacheSize,
          'totalSize': '${newTotalSize.toStringAsFixed(1)} MB',
        };
      });
    }
  }

  static const List<Map<String, String>> _initialApps = [
    {'name': 'Chrome', 'icon': 'assets/icons/chrome.png', 'version': '124.0.0.0'},
    {'name': 'Gmail', 'icon': 'assets/icons/gmail.png', 'version': '2024.04.28.623192461'},
    {'name': 'Maps', 'icon': 'assets/icons/maps.png', 'version': '11.125.0101'},
     {'name': 'Settings', 'icon': 'assets/icons/settings.png', 'version': '1.0.0'},
    {'name': 'Photos', 'icon': 'assets/icons/photos.png', 'version': '6.84.0.621017366'},
    {'name': 'YouTube', 'icon': 'assets/icons/youtube.png', 'version': '19.18.33'},
    {'name': 'Drive', 'icon': 'assets/icons/drive.png', 'version': '2.24.167.0.90'},
    {'name': 'Calendar', 'icon': 'assets/icons/calendar.png', 'version': '2024.17.0-629237913-release'},
    {'name': 'Clock', 'icon': 'assets/icons/clock.png', 'version': '8.2.0'},
    {'name': 'Camera', 'icon': 'assets/icons/camera.png', 'version': '9.2.100.612808000'},
    {'name': 'Play Store', 'icon': 'assets/icons/playstore.png', 'version': '40.6.31-21'},
    {'name': 'Files', 'icon': 'assets/icons/files.png', 'version': '1.0.623214532'},
    {'name': 'Calculator', 'icon': 'assets/icons/calculator.png', 'version': '8.2 (531942488)'},
    {'name': 'Messages', 'icon': 'assets/icons/messages.png', 'version': '20240424_02_RC00.phone_dynamic'},
    {'name': 'Phone', 'icon': 'assets/icons/phone.png', 'version': '124.0.0.612808000'},
    {'name': 'Contacts', 'icon': 'assets/icons/contacts.png', 'version': '4.29.17.625340050'},
    {'name': 'Weather', 'icon': 'assets/icons/weather.png', 'version': '1.0'},
    {'name': 'Spotify', 'icon': 'assets/icons/spotify.png', 'version': '8.9.36.568'},
    {'name': 'WhatsApp', 'icon': 'assets/icons/whatsapp.png', 'version': '2.24.10.74'},
    {'name': 'Instagram', 'icon': 'assets/icons/instagram.png', 'version': '312.0.0.32.112'},
    {'name': 'Netflix', 'icon': 'assets/icons/netflix.png', 'version': '8.100.1'},
    {'name': 'Facebook', 'icon': 'assets/icons/facebook.png', 'version': '473.0.0.35.109'},
    {'name': 'Twitter', 'icon': 'assets/icons/twitter.png', 'version': '10.37.0-release.0'},
    {'name': 'Snapchat', 'icon': 'assets/icons/snapchat.png', 'version': '12.87.0.40'},
    {'name': 'TikTok', 'icon': 'assets/icons/tiktok.png', 'version': '34.8.4'},
    {'name': 'Pinterest', 'icon': 'assets/icons/pinterest.png', 'version': '11.20.0'},
    {'name': 'Amazon', 'icon': 'assets/icons/amazon.png', 'version': '25.21.1.800'},
   
  ];

  List<Map<String, String>> _generateRandomAppSizes(List<Map<String, String>> apps) {
    return apps.map((app) {
      final double appSizeMB = _random.nextDouble() * (200 - 50) + 50;
      final double dataSizeMB = _random.nextDouble() * (100 - 10) + 10;
      final double cacheSizeMB = _random.nextDouble() * (50 - 5) + 5;
      final double totalSizeMB = appSizeMB + dataSizeMB + cacheSizeMB;

      return {
        ...app,
        'appSize': '${appSizeMB.toStringAsFixed(1)} MB',
        'dataSize': '${dataSizeMB.toStringAsFixed(1)} MB',
        'cacheSize': '${cacheSizeMB.toStringAsFixed(1)} MB',
        'totalSize': '${totalSizeMB.toStringAsFixed(1)} MB',
      };
    }).toList();
  }

  Future<void> scrollToApp(String appName) async {
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final DateTime startTime = DateTime.now();
    final int randomScrollDurationSeconds = _random.nextInt(6) + 10; // 10 to 15 seconds

    final List<Curve> curves = [
      Curves.easeInOut,
      Curves.bounceInOut,
      Curves.elasticInOut,
      Curves.linear,
      Curves.easeInCubic,
      Curves.easeOutCirc,
    ];

    while (DateTime.now().difference(startTime).inSeconds < randomScrollDurationSeconds) {
      final double randomPosition = _random.nextDouble() * maxScroll;
      final int randomDurationMs = _random.nextInt(1001) + 500; // 500ms to 1500ms
      final Curve randomCurve = curves[_random.nextInt(curves.length)];

      // Removed: captionNotifier?.value = 'Randomly scrolling...';

      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          randomPosition,
          duration: Duration(milliseconds: randomDurationMs),
          curve: randomCurve,
        );
      }
      await Future.delayed(Duration(milliseconds: randomDurationMs)); // Wait for animation
    }

    // Original logic to scroll to the target app
    final index = _apps.indexWhere((app) => app['name'] == appName);
    if (index != -1) {
      const double itemHeight = 100; // Adjusted for typical item height
      final double offset = (index ~/ 3) * itemHeight;
      // Ensure the offset does not exceed maxScrollExtent
      final double targetOffset = min(offset, maxScroll);
      
      // Removed: captionNotifier?.value = 'Scrolling to "$appName".';

      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      // --- NEW: Ensure visibility below notification panel ---
      await _ensureAppVisibleAfterScroll(appName);
    }
  }

  // NEW METHOD: Ensures the app is visible below the notification drawer
  // This method is now correctly placed within AppGridState.
  Future<void> _ensureAppVisibleAfterScroll(String appName) async {
    final GlobalKey<ClickableOutlineState>? appKey = appItemKeys[appName];
    if (appKey == null || appKey.currentContext == null) return;

    // Wait for the UI to rebuild after the initial scroll animation
    // This is important to get accurate render box information.
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    final RenderBox renderBox = appKey.currentContext!.findRenderObject() as RenderBox;
    final Offset appPosition = renderBox.localToGlobal(Offset.zero);

    // Get the current height of the notification drawer from the PhoneMockupContainerState
    final double currentNotificationDrawerHeight = widget.phoneMockupKey.currentState?.currentNotificationDrawerHeight ?? 0.0;

    // Calculate app's Y position relative to the top of the phone mockup content area
    // The phone mockup's content starts below the status bar (30px).
    final phoneMockupRenderBox = widget.phoneMockupKey.currentContext?.findRenderObject() as RenderBox?;
    if (phoneMockupRenderBox == null) return;
    final Offset phoneMockupGlobalPosition = phoneMockupRenderBox.localToGlobal(Offset.zero);

    // appPosition.dy is global. Subtract phoneMockupGlobalPosition.dy to get relative position within mockup.
    // Then subtract the status bar height (30px) to get position relative to the scrollable content area.
    final double appYRelativeToPhoneContent = appPosition.dy - (phoneMockupGlobalPosition.dy + 30.0); // 30.0 is status bar height

    // The threshold should be the bottom edge of the notification drawer when it's open.
    // Plus some buffer to ensure the app is comfortably visible.
    const double buffer = 20.0; // A small buffer so the app isn't right at the edge

    if (appYRelativeToPhoneContent < currentNotificationDrawerHeight + buffer) {
      final double scrollAmount = (currentNotificationDrawerHeight + buffer) - appYRelativeToPhoneContent;
      final double newOffset = _scrollController.offset + scrollAmount;

      // Ensure newOffset does not exceed maxScrollExtent
      final double finalOffset = min(newOffset, _scrollController.position.maxScrollExtent);

      if (_scrollController.offset != finalOffset) {
        // Removed: widget.phoneMockupKey.currentState?.widget.currentCaption.value = 'Adjusting scroll to make "$appName" visible.';
        if (_scrollController.hasClients) {
          await _scrollController.animateTo(
            finalOffset,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      }
    }
  }

  Future<void> performSlowRandomScroll(Duration totalDuration) async {
    if (!_scrollController.hasClients || _scrollController.position.maxScrollExtent <= 0) {
      print("AppGridState: Cannot perform slow scroll, ScrollController not ready or no scroll extent.");
      return;
    }

    final DateTime overallStartTime = DateTime.now();
    final double maxScroll = _scrollController.position.maxScrollExtent;
    final List<Curve> curves = [
      Curves.easeInOut, Curves.linear, Curves.easeInQuad, Curves.easeOutQuad
    ];

    print("AppGridState: Starting slow random scroll for ${totalDuration.inSeconds} seconds.");
    // Removed: phoneMockupKey.currentState?.widget.currentCaption.value = "Performing slow random scroll...";


    while (DateTime.now().difference(overallStartTime) < totalDuration) {
      final int scrollAnimMillis = _random.nextInt(1001) + 500;
      if (DateTime.now().difference(overallStartTime) + Duration(milliseconds: scrollAnimMillis) > totalDuration) {
        break;
      }

      final double randomPosition = _random.nextDouble() * maxScroll;
      final Curve randomCurve = curves[_random.nextInt(curves.length)];

      print("AppGridState: Slow scrolling to ${randomPosition.toStringAsFixed(1)} over ${scrollAnimMillis}ms.");
      await _scrollController.animateTo(
        randomPosition,
        duration: Duration(milliseconds: scrollAnimMillis),
        curve: randomCurve,
      );

      if (DateTime.now().difference(overallStartTime) >= totalDuration) {
        break; 
      }

      final int pauseMillis = _random.nextInt(1501) + 500;
      if (DateTime.now().difference(overallStartTime) + Duration(milliseconds: pauseMillis) > totalDuration) {
        break;
      }
      
      print("AppGridState: Pausing for ${pauseMillis}ms.");
      await Future.delayed(Duration(milliseconds: pauseMillis));
    }
    print("AppGridState: Finished slow random scroll.");
    // Removed: phoneMockupKey.currentState?.widget.currentCaption.value = "Finished random scrolling.";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.wallpaperImage != null
          ? BoxDecoration(
              image: DecorationImage(
                image: FileImage(widget.wallpaperImage!),
                fit: BoxFit.cover,
              ),
            )
          : const BoxDecoration(
              color: Colors.white,
            ),
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 1.0,
        ),
        itemCount: _apps.length,
        itemBuilder: (context, index) {
          final app = _apps[index];
          final appName = app['name']!;
          final String iconPath = app['icon']!;

          Widget iconWidget;
          if (iconPath.startsWith('assets/')) {
            iconWidget = Image.asset(
              iconPath,
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading asset: $iconPath");
                return const Icon(Icons.broken_image, size: 48);
              },
            );
          } else {
            iconWidget = Image.file(
              File(iconPath),
              width: 48,
              height: 48,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print("Error loading file: $iconPath - $error");
                return const Icon(Icons.broken_image, size: 48);
              },
            );
          }

          final GlobalKey<ClickableOutlineState> itemKey = appItemKeys[appName] ?? (appItemKeys[appName] = GlobalKey<ClickableOutlineState>());

          Future<void> appAction() async {
            widget.phoneMockupKey.currentState?.handleAppLongPress(app);
          }

          return ClickableOutline(
            key: itemKey,
            action: appAction,
            // Removed specificCaption and caption here to rely on parent's _handleStep
            // or specific actions set by phone_mockup_container
            child: GestureDetector(
              onTap: () {
                if (widget.onAppTap != null) {
                  // The actual caption will be set by handleItemTap in phone_mockup_container
                  widget.onAppTap!(app['name']!, itemDetails: app);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Tap action not configured for ${app['name']}.")),
                  );
                }
              },
              onLongPress: () {
                // The actual caption will be set by handleAppLongPress in phone_mockup_container
                widget.phoneMockupKey.currentState?.handleAppLongPress(app);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconWidget,
                  const SizedBox(height: 8),
                  Text(
                    appName.length > 9 ? '${appName.substring(0, 9)}...' : appName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}