// lib/tool_drawer.dart
import 'app_automation_simulator.dart';
import 'package:flutter/material.dart';
import 'phone_mockup/app_grid.dart';
import 'phone_mockup/phone_mockup_container.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'phone_mockup/wallpaper_settings.dart';

class ToolDrawer extends StatefulWidget {
  final AppAutomationSimulator appAutomationSimulator; // Pass simulator instance
  final File? pickedImage;
  final Function(File?) onImageChanged;
  final Function(File?) onFrameImageChanged;
  final Function(double, double) onImagePan;
  final Function(double) onImageScale;
  final VoidCallback onClose;
  final double currentImageScale;
  final GlobalKey<PhoneMockupContainerState> phoneMockupKey;
  final GlobalKey<AppGridState> appGridKey;
  final Function(File?) onWallpaperChanged;
  final VoidCallback onRemoveWallpaper;
  final File? currentWallpaper;
  final Function(File?) onMockupWallpaperChanged;
  final VoidCallback onStartWaiting;

  const ToolDrawer({
    super.key,
    required this.appAutomationSimulator,
    required this.pickedImage,
    required this.onImageChanged,
    required this.onFrameImageChanged,
    required this.onImagePan,
    required this.onImageScale,
    required this.onClose,
    required this.currentImageScale,
    required this.phoneMockupKey,
    required this.appGridKey,
    required this.onWallpaperChanged,
    required this.onRemoveWallpaper,
    required this.onMockupWallpaperChanged,
    this.currentWallpaper,
    required this.onStartWaiting,
  });

  @override
  State<ToolDrawer> createState() => ToolDrawerState();
}

class ToolDrawerState extends State<ToolDrawer> {
  late TextEditingController _commandController;
  bool _isSimulationRunning = false;

  @override
  void initState() {
    super.initState();
    _commandController = TextEditingController();
  }

  @override
  void dispose() {
    _commandController.dispose();
    super.dispose();
  }

  Map<String, String>? _parseCommand(String command) {
    final lowerCaseCommand = command.toLowerCase().trim();
    final clearDataKeyword = 'clear data';
    final resetNetworkKeyword = 'reset network';

    if (lowerCaseCommand.contains(clearDataKeyword)) {
      final clearDataIndex = lowerCaseCommand.indexOf(clearDataKeyword);
      if (clearDataIndex > 0) {
        final appName = command.substring(0, clearDataIndex).trim();
        if (appName.isNotEmpty) {
          return {'appName': appName, 'action': 'clearDataAndResetNetwork'};
        }
      }
    } else if (lowerCaseCommand == resetNetworkKeyword) {
      return {'action': 'resetNetworkOnly'};
    }
    return null;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      widget.onImageChanged(File(image.path));
    }
  }

  void _dismissImage() {
    widget.onImageChanged(null);
  }

  Future<void> _pickIcons() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> pickedFiles = await picker.pickMultipleMedia();

    if (pickedFiles.isNotEmpty) {
      List<Map<String, String>> newIcons = [];
      for (var file in pickedFiles) {
        if (newIcons.length >= 50) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Processing the first 50 selected icons.")),
            );
          }
          break;
        }
        String iconName = p.basenameWithoutExtension(file.path);
        newIcons.add({'name': iconName, 'icon': file.path});
      }

      if (newIcons.isNotEmpty) {
        widget.appGridKey.currentState?.addIcons(newIcons);
      }
    }
  }

  Future<void> _pickFrameImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      widget.onFrameImageChanged(File(image.path));
    }
  }

  void _dismissFrameImage() {
    widget.onFrameImageChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 200,
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              bottomLeft: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(-5, 0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tools',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.black54),
                        onPressed: widget.onClose,
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: const Text('Add Image'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (widget.pickedImage != null)
                    ElevatedButton.icon(
                      onPressed: _dismissImage,
                      icon: const Icon(Icons.delete),
                      label: const Text('Remove Image'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickFrameImage,
                    icon: const Icon(Icons.filter_hdr_outlined),
                    label: const Text('Import Frame'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _dismissFrameImage,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove Frame'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => WallpaperSettingsScreen(
                            onWallpaperChanged: widget.onWallpaperChanged,
                            onRemoveWallpaper: widget.onRemoveWallpaper,
                            currentWallpaper: widget.currentWallpaper,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.wallpaper),
                    label: const Text('Change Wallpaper'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        widget.onMockupWallpaperChanged(File(image.path));
                      }
                    },
                    icon: const Icon(Icons.photo_size_select_actual_outlined),
                    label: const Text('Set Mockup WP'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      widget.onMockupWallpaperChanged(null);
                    },
                    icon: const Icon(Icons.hide_image_outlined),
                    label: const Text('Remove Mockup WP'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                      backgroundColor: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: _pickIcons,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Icons'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const Divider(height: 30, thickness: 1),
                  const Text(
                    'Image Controls:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Scale:'),
                      SizedBox(
                        width: 100,
                        child: Slider(
                          value: widget.currentImageScale,
                          min: 0.1,
                          max: 5.0,
                          divisions: 49,
                          onChanged: widget.onImageScale,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => widget.onImagePan(-10.0, 0.0),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => widget.onImagePan(10.0, 0.0),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_upward),
                        onPressed: () => widget.onImagePan(0.0, -10.0),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_downward),
                        onPressed: () => widget.onImagePan(0.0, 10.0),
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),
                  const Text(
                    'Command Input:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: _commandController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter commands (CSV)',
                        isDense: true,
                      ),
                      onSubmitted: (_) => _handleRunCommand(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: _isSimulationRunning ? null : _handleRunCommand,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: _isSimulationRunning ? Colors.grey : null,
                      ),
                      child: Text(_isSimulationRunning ? 'Simulating...' : 'Run Commands'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRunCommand() async {
    if (_isSimulationRunning) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Simulations already in progress."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final String allCommandsText = _commandController.text;
    final List<String> commands = allCommandsText
        .split(',')
        .map((cmd) => cmd.trim())
        .where((cmd) => cmd.isNotEmpty)
        .toList();

    if (commands.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No command entered."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSimulationRunning = true;
      });
      widget.onClose();
    }

    try {
      for (int i = 0; i < commands.length; i++) {
        if (i > 0) {
          widget.phoneMockupKey.currentState?.widget.currentCaption.value = 'Waiting for 1 minute before executing the next command...';
          widget.onStartWaiting();
          await Future.delayed(const Duration(minutes: 1));
        }

        final String command = commands[i];
        final String appName = command.split(' clear data').first.trim();
        
        widget.phoneMockupKey.currentState?.widget.currentCaption.value = "Preparing '$appName' for action...";
        widget.appGridKey.currentState?.moveAppToBottomIfNeeded(appName);
        await Future.delayed(const Duration(seconds: 2));

        widget.appGridKey.currentState?.shuffleMiddleApps();
        await Future.delayed(const Duration(milliseconds: 500));

        widget.phoneMockupKey.currentState?.widget.currentCaption.value = 'Executing command ${i + 1}/${commands.length}: "$command"';
        await Future.delayed(const Duration(seconds: 2));

        final parsedCommand = _parseCommand(command);

        if (parsedCommand != null) {
          bool simulationSucceeded = false;
          final action = parsedCommand['action'];

          if (action == 'clearDataAndResetNetwork') {
              simulationSucceeded = await widget.appAutomationSimulator.startClearDataAndResetNetworkSimulation(appName);
          } else if (action == 'resetNetworkOnly') {
            final phoneState = widget.phoneMockupKey.currentState;
            final gridState = widget.appGridKey.currentState;
            if (phoneState != null && gridState != null) {
              simulationSucceeded = await widget.appAutomationSimulator.startResetNetworkSimulation(phoneState, gridState);
            } else {
              print("Error: Could not get phone or grid state.");
            }
          }

          if (!simulationSucceeded && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Simulation failed for command: '$command'."),
                backgroundColor: Colors.red,
              ),
            );
            break;
          }

        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Unknown command: '$command'"),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
      widget.phoneMockupKey.currentState?.widget.currentCaption.value = 'All commands have been executed.';
    } finally {
      if (mounted) {
        widget.appGridKey.currentState?.resetGrid();
        setState(() {
          _isSimulationRunning = false;
        });
      }
    }
  }
}
