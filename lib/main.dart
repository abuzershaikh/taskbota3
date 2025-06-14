import 'package:flutter/material.dart';
 
import 'package:flutter_box_transform/flutter_box_transform.dart'; // Import flutter_box_transform
import 'phone_mockup/app_grid.dart'; // Import for AppGridState
import 'package:phone_ui_training/phone_mockup/phone_mockup_container.dart';
import 'dart:io';
import 'tool_drawer.dart';
import 'command_service.dart';
import 'command_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Initialize GlobalKeys as instance variables
  final GlobalKey<PhoneMockupContainerState> _phoneMockupKey = GlobalKey<PhoneMockupContainerState>();
  final GlobalKey<AppGridState> _appGridKey = GlobalKey<AppGridState>(); // Correctly typed key for AppGrid

  late final CommandService _commandService;
  late final CommandController _commandController;

  File? _backgroundImage;
  File? _pickedImage;
  double _imageX = 0;
  double _imageY = 0;
  double _imageScale = 1.0;
  double _lastScale = 1.0;

  // State variables for the frame image
  @visibleForTesting
  File? _frameImage;
  Rect? _frameRect; // Using Rect for flutter_box_transform

  File? _mockupWallpaperImage; // Added mockup wallpaper image state

  bool _isToolDrawerOpen = false;

  void _onImageChanged(File? newImage) {
    setState(() {
      _pickedImage = newImage;
      if (newImage != null) {
        _imageX = 0;
        _imageY = 0;
        _imageScale = 1.0;
        _lastScale = 1.0;
      }
    });
  }

  void _onMockupWallpaperChanged(File? newImage) { // Added callback for mockup wallpaper
    setState(() {
      _mockupWallpaperImage = newImage;
    });
  }

  // Method to handle frame image changes
  @visibleForTesting
  void _onFrameImageChanged(File? newFrameImage) {
    setState(() {
      _frameImage = newFrameImage;
      if (newFrameImage == null) {
        _frameRect = null; // Clear rect if image is removed
      } else {
        // Initial rect will be set in build method when context is available
        // to correctly center it. For now, just nullify it so build can init.
        _frameRect = null; 
      }
    });
  }

  // _onFramePan and _onFrameScale are no longer needed as TransformableBox handles this.

  void _onImagePan(double dx, double dy) {
    setState(() {
      _imageX += dx;
      _imageY += dy;
    });
  }

  void _onImageScale(double scale) {
    setState(() {
      _imageScale = scale;
      _imageScale = _imageScale.clamp(0.1, 5.0);
    });
  }

  void _toggleToolDrawer() {
    setState(() {
      _isToolDrawerOpen = !_isToolDrawerOpen;
      // print('main.dart: Tool Drawer toggled. Open: $_isToolDrawerOpen');
    });
  }

  void _closeToolDrawer() {
    if (_isToolDrawerOpen) {
      setState(() {
        _isToolDrawerOpen = false;
        // print('main.dart: Tool Drawer closed via callback.');
      });
    }
  }

  void _onWallpaperChanged(File? newImage) {
    setState(() {
      _backgroundImage = newImage;
    });
  }

  void _removeWallpaper() {
    setState(() {
      _backgroundImage = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _commandService = CommandService();
    _commandController = CommandController(_commandService, _phoneMockupKey);
    _commandService.onNewPythonCommand = _commandController.processCommand;
    _commandService.startPolling();
  }

  @override
  void dispose() {
    _commandService.stopPolling();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const double imageBaseSize = 100.0;
    const double frameBaseSize = 300.0; // Base size for the frame
    const double kTransparentHandleSize = 24.0; // Default handleTapSize is 24.0
    // print(
    //   'main.dart: build method called. Screen size: $screenWidth x $screenHeight',
    // );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phone Mockup Editor',
      home: Scaffold(
        body: Container(
          decoration: _backgroundImage != null
              ? BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_backgroundImage!),
                    fit: BoxFit.cover,
                  ),
                )
              : const BoxDecoration(
                  color: Colors.grey, // Default background color
                ),
          child: Stack(
            children: [
              Align(
                alignment: Alignment.center,
 child: PhoneMockupContainer(key: _phoneMockupKey, appGridKey: _appGridKey, mockupWallpaperImage: _mockupWallpaperImage,), // Pass the key and mockup wallpaper
              ),

              if (_pickedImage != null)
              Positioned(
                left:
                    screenWidth / 2 -
                    (imageBaseSize * _imageScale) / 2 +
                    _imageX,
                top:
                    screenHeight / 2 -
                    (imageBaseSize * _imageScale) / 2 +
                    _imageY,
                child: GestureDetector(
                  onScaleStart: (details) {
                    _lastScale = _imageScale;
                  },
                  onScaleUpdate: (details) {
                    setState(() {
                      _imageX += details.focalPointDelta.dx;
                      _imageY += details.focalPointDelta.dy;
                      _imageScale = _lastScale * details.scale;
                      _imageScale = _imageScale.clamp(0.1, 5.0);
                    });
                  },
                  child: Transform.scale(
                    scale: _imageScale,
                    child: Image.file(
                      _pickedImage!,
                      width: imageBaseSize,
                      height: imageBaseSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            
            // Display the Frame Image using TransformableBox
            if (_frameImage != null) ...[
              Builder( // Use Builder to ensure context for MediaQuery is up-to-date
                builder: (context) {
                  if (_frameRect == null) {
                    // Initialize _frameRect here if it's null (e.g., after image pick)
                    // This ensures screenWidth and screenHeight are available from a current context.
                    final currentScreenWidth = MediaQuery.of(context).size.width;
                    final currentScreenHeight = MediaQuery.of(context).size.height;
                    _frameRect = Rect.fromLTWH(
                      currentScreenWidth / 2 - frameBaseSize / 2,
                      currentScreenHeight / 2 - frameBaseSize / 2,
                      frameBaseSize,
                      frameBaseSize,
                    );
                  }
                  // Ensure _frameRect is not null before building TransformableBox
                  if (_frameRect == null) return const SizedBox.shrink();

                  return TransformableBox(
                    rect: _frameRect!,
                    onChanged: (UITransformResult result, DragUpdateDetails? event) { // Corrected signature
                      setState(() {
                        _frameRect = result.rect;
                      });
                    },
                    contentBuilder: (BuildContext context, Rect rect, Flip flip) {
                      return Image.file(
                        _frameImage!,
                        fit: BoxFit.fill, // Fill the bounds of the TransformableBox
                        width: rect.width,
                        height: rect.height,
                      );
                    },
                    cornerHandleBuilder: (BuildContext context, HandlePosition handle) {
                      return Container(
                        width: kTransparentHandleSize,
                        height: kTransparentHandleSize,
                        color: Colors.transparent,
                      );
                    },
                    sideHandleBuilder: (BuildContext context, HandlePosition handle) {
                      return Container(
                        width: kTransparentHandleSize,
                        height: kTransparentHandleSize,
                        color: Colors.transparent,
                      );
                    },
                  );
                }
              ),
            ],

            // Tool Drawer Toggle Button
            Positioned(
              right: 20,
              
              top: screenHeight / 2 - 25,
              child: FloatingActionButton(
                onPressed: _toggleToolDrawer,
                mini: true,
                backgroundColor: Colors.blue,
                child: Icon(_isToolDrawerOpen ? Icons.close : Icons.build),
              ),
            ),

            // The Tool Drawer Itself
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              right: _isToolDrawerOpen ? 0 : -200,
              top: 0,
              bottom: 0,
              child: ToolDrawer(
                pickedImage: _pickedImage,
                onImageChanged: _onImageChanged,
                onFrameImageChanged: _onFrameImageChanged, // Pass the new callback
                onImagePan: _onImagePan,
                onImageScale: _onImageScale,
                currentImageScale: _imageScale,
                onClose: _closeToolDrawer,
                onWallpaperChanged: _onWallpaperChanged,
                onRemoveWallpaper: _removeWallpaper,
                onMockupWallpaperChanged: _onMockupWallpaperChanged, // Pass the new callback
                phoneMockupKey: _phoneMockupKey, // Pass instance variable _phoneMockupKey
                appGridKey: _appGridKey,       // Pass instance variable _appGridKey
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}