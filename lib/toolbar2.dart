import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Import file_picker

class Toolbar2 extends StatefulWidget {
  final Function(File?) onWallpaperPicked;

  const Toolbar2({super.key, required this.onWallpaperPicked});

  @override
  State<Toolbar2> createState() => _Toolbar2State();
}

class _Toolbar2State extends State<Toolbar2> {
  File? _pickedImage;

  Future<void> _pickMockupWallpaper() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _pickedImage = File(result.files.single.path!);
        });
        widget.onWallpaperPicked(_pickedImage); // Notify the parent widget
      } else {
        // User canceled the picker
        // Optionally, notify with null if you want to clear a previously picked image
        // widget.onWallpaperPicked(null);
        print("File picking cancelled or path was null.");
      }
    } catch (e) {
      // Handle any errors from file picking
      print("Error picking file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error picking file: $e")),
      );
      widget.onWallpaperPicked(null); // Notify with null in case of error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200], // Example background color for the toolbar
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Toolbar2", 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.image_search_outlined), // Using an outlined icon
            label: const Text('Pick Wallpaper for Mockup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary, // Use primary color
              foregroundColor: Theme.of(context).colorScheme.onPrimary, // Use onPrimary for text/icon
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              textStyle: const TextStyle(fontSize: 16),
            ),
            onPressed: _pickMockupWallpaper,
          ),
          if (_pickedImage != null) ...[
            const SizedBox(height: 12),
            Text(
              "Selected: ${_pickedImage!.path.split('/').last}",
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Display a small preview of the picked image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                _pickedImage!,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
          ]
        ],
      ),
    );
  }
}
