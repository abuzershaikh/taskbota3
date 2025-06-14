import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class WallpaperSettingsScreen extends StatefulWidget {
  final Function(File?) onWallpaperChanged;
  final VoidCallback onRemoveWallpaper;
  final File? currentWallpaper;

  const WallpaperSettingsScreen({
    super.key,
    required this.onWallpaperChanged,
    required this.onRemoveWallpaper,
    this.currentWallpaper,
  });

  @override
  State<WallpaperSettingsScreen> createState() => _WallpaperSettingsScreenState();
}

class _WallpaperSettingsScreenState extends State<WallpaperSettingsScreen> {
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.currentWallpaper;
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    // Attempt to pick an image from the gallery
    // We cannot easily restrict to a specific "wallpaper" folder using the standard picker.
    // This will open the general gallery.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _applyWallpaper() {
    widget.onWallpaperChanged(_selectedImage);
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _removeWallpaper() {
    widget.onRemoveWallpaper();
    setState(() {
      _selectedImage = null;
    });
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallpaper Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image from Gallery'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _selectedImage != null
                    ? Image.file(
                        _selectedImage!,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'No image selected',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _selectedImage != null ? _applyWallpaper : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Apply Wallpaper'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _removeWallpaper,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove Wallpaper'),
            ),
          ],
        ),
      ),
    );
  }
}
