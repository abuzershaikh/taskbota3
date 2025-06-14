import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// AppInfoScreen ka import ab zaroori nahi hai, kyunki navigation parent handle karega.

class SystemAppScreen extends StatefulWidget {
  final VoidCallback onBack;
  // Naya callback function, jo app select hone par call hoga.
  final void Function(Map<String, String> app) onAppSelected;

  const SystemAppScreen({
    super.key,
    required this.onBack,
    required this.onAppSelected, // Constructor mein add karein.
  });

  @override
  State<SystemAppScreen> createState() => _SystemAppScreenState();
}

class _SystemAppScreenState extends State<SystemAppScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allSystemApps = [];
  List<Map<String, String>> _filteredSystemApps = [];
  bool _isLoading = true;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _loadSystemIcons();
    _searchController.addListener(_filterApps);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterApps);
    _searchController.dispose();
    super.dispose();
  }

  String _generateRandomAppSize() {
    // Use the existing _random instance
    final units = ['KB', 'MB', 'GB'];
    String unit = units[_random.nextInt(units.length)];
    double size;

    if (unit == 'KB') {
      size = (_random.nextInt(900) + 100).toDouble(); // 100-999 KB
      return '${size.toInt()} KB';
    } else if (unit == 'MB') {
      size = _random.nextDouble() * 500 + 1; // 1.0 - 500.9 MB
      if (_random.nextBool()) { // Occasionally make it a whole number
          return '${size.toInt()} MB';
      }
      return '${size.toStringAsFixed(1)} MB';
    } else { // GB
      size = _random.nextDouble() * 5 + 0.5; // 0.5 - 5.4 GB
      return '${size.toStringAsFixed(1)} GB';
    }
  }

  Future<void> _loadSystemIcons() async {
    try {
      final manifestContent =
          await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);
      final List<Map<String, String>> foundIcons = [];

      for (var key in manifestMap.keys) {
        if (key.startsWith('assets/systemicon/')) {
          String namePart = key
              .substring('assets/systemicon/'.length)
              .replaceAll('_', ' ');
          final dotIndex = namePart.lastIndexOf('.');
          if (dotIndex != -1) {
            namePart = namePart.substring(0, dotIndex);
          }
          
          // AppInfoScreen ke liye zaroori data add karein.
          foundIcons.add({
            'name': namePart,
            'icon': key,
            'version': '9.${_random.nextInt(5)}.${_random.nextInt(10)}',
            'totalSize': _generateRandomAppSize(),
          });
        }
      }

      if (mounted) {
        setState(() {
          _allSystemApps = foundIcons;
          _filteredSystemApps = _allSystemApps;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading system icons: $e');
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
      _filteredSystemApps = _allSystemApps.where((app) {
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
        title: const Text(
          "System Apps",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blueGrey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: widget.onBack,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search ${_allSystemApps.length} items',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 20),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: Colors.white,
                    child: ListView.separated(
                      itemCount: _filteredSystemApps.length,
                      separatorBuilder: (context, index) => const Divider(
                        height: 1, indent: 72, endIndent: 16, color: Colors.black12,
                      ),
                      itemBuilder: (context, index) {
                        final app = _filteredSystemApps[index];
                        return ListTile(
                          leading: Image.asset(
                            app['icon']!,
                            width: 40, height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, size: 40);
                            },
                          ),
                          title: Text(app['name']!),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () {
                            // Parent widget ko batayein ki app select ho gaya hai.
                            widget.onAppSelected(app);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
