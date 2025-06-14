import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// AppInfoScreen ka import ab yahan zaroori nahi hai.

class AppManagementScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNavigateToSystemApps;
  // Naya callback function, jo app select hone par call hoga.
  final void Function(Map<String, String> app) onAppSelected;

  const AppManagementScreen({
    super.key,
    required this.onBack,
    required this.onNavigateToSystemApps,
    required this.onAppSelected, // Constructor mein add karein.
  });

  @override
  State<AppManagementScreen> createState() => _AppManagementScreenState();
}

class _AppManagementScreenState extends State<AppManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allApps = [];
  List<Map<String, String>> _filteredApps = [];
  bool _isLoading = true;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _loadAppsFromAssets();
    _searchController.addListener(_filterApps);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterApps);
    _searchController.dispose();
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

  Future<void> _loadAppsFromAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      final List<Map<String, String>> loadedIcons = [];
      for (var assetPath in manifestMap.keys) {
        if (assetPath.startsWith('assets/icons/')) {
          String fileName = assetPath.substring('assets/icons/'.length);
          String appName = fileName.split('.').first;

          // AppInfoScreen ke liye zaroori data add karein.
          loadedIcons.add({
            'name': appName,
            'icon': assetPath,
            'version': '1.${_random.nextInt(12)}.${_random.nextInt(20)}',
            'totalSize': _generateRandomAppSize(),
          });
        }
      }

      if (mounted) {
        setState(() {
          _allApps = loadedIcons;
          _filteredApps = _allApps;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading app icons from assets: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredApps = _allApps.where((app) {
        final appName = app['name']?.toLowerCase() ?? '';
        return appName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: const Text("App management", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.blueGrey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'show_system_apps') {
                widget.onNavigateToSystemApps();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'show_system_apps',
                child: Text('Show system apps'),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ${_allApps.length} items',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredApps.length,
                    itemBuilder: (context, index) {
                      final app = _filteredApps[index];
                      return Column(
                        children: [
                          ListTile(
                            leading: Image.asset(
                              app['icon']!,
                              width: 40, height: 40, fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 40);
                              },
                            ),
                            title: Text(
                              app['name']!,
                              style: const TextStyle(fontSize: 16, color: Colors.black87),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            onTap: () {
                              // Parent widget ko batayein ki app select ho gaya hai.
                              widget.onAppSelected(app);
                            },
                          ),
                          if (index < _filteredApps.length - 1)
                            const Divider(
                              indent: 72, endIndent: 16, height: 1, color: Colors.black12,
                            ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
