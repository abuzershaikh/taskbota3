// lib/main.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:phone_ui_training/phone_mockup/phone_mockup_container.dart';
import 'phone_mockup/app_grid.dart';
import 'dart:io';
import 'tool_drawer.dart';
import 'command_service.dart';
import 'command_controller.dart';
import 'caption_display.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<PhoneMockupContainerState> _phoneMockupKey = GlobalKey<PhoneMockupContainerState>();
  final GlobalKey<AppGridState> _appGridKey = GlobalKey<AppGridState>();

  late final CommandService _commandService;
  late final CommandController _commandController;

  final ValueNotifier<String> _currentCaption = ValueNotifier<String>('No action yet.');

  File? _backgroundImage;
  File? _pickedImage;
  double _imageX = 0;
  double _imageY = 0;
  double _imageScale = 1.0;
  double _lastScale = 1.0;

  @visibleForTesting
  File? _frameImage;
  Rect? _frameRect;

  File? _mockupWallpaperImage;

  bool _isToolDrawerOpen = false;

  late BoxDecoration _backgroundDecoration;

  @override
  void initState() {
    super.initState();
    _backgroundDecoration = _createRandomGradient(); // Updated function call

    _commandService = CommandService();
    _commandController = CommandController(_commandService, _phoneMockupKey);
    _commandService.onNewPythonCommand = _commandController.processCommand;
    _commandService.startPolling();
  }

  // Updated function to generate fully random gradients
  BoxDecoration _createRandomGradient() {
    final Random random = Random();
    final Color color1 = Color.fromARGB(
      255, // Alpha (fully opaque)
      random.nextInt(256), // Red (0-255)
      random.nextInt(256), // Green (0-255)
      random.nextInt(256), // Blue (0-255)
    );
    final Color color2 = Color.fromARGB(
      255, // Alpha (fully opaque)
      random.nextInt(256), // Red (0-255)
      random.nextInt(256), // Green (0-255)
      random.nextInt(256), // Blue (0-255)
    );
    
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [color1, color2],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  void _changeBackgroundGradient() {
    setState(() {
      _backgroundDecoration = _createRandomGradient(); // Updated function call
    });
  }

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

  void _onMockupWallpaperChanged(File? newImage) {
    setState(() {
      _mockupWallpaperImage = newImage;
    });
  }

  @visibleForTesting
  void _onFrameImageChanged(File? newFrameImage) {
    setState(() {
      _frameImage = newFrameImage;
      if (newFrameImage == null) {
        _frameRect = null;
      } else {
        _frameRect = null;
      }
    });
  }

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
    });
  }

  void _closeToolDrawer() {
    if (_isToolDrawerOpen) {
      setState(() {
        _isToolDrawerOpen = false;
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
  void dispose() {
    _commandService.stopPolling();
    _currentCaption.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const double imageBaseSize = 100.0;
    const double frameBaseSize = 300.0;
    const double kTransparentHandleSize = 24.0;
    const double phoneMockupWidth = 300.0;
    const double captionDisplayWidth = 250.0;
    const double captionDisplayHeight = 150.0;
    const double spacing = 20.0;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phone Mockup Editor',
      home: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          decoration: _backgroundImage != null
              ? BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(_backgroundImage!),
                    fit: BoxFit.cover,
                  ),
                )
              : _backgroundDecoration,
          child: Stack(
            children: [
              Center(
                child: PhoneMockupContainer(
                  key: _phoneMockupKey,
                  appGridKey: _appGridKey,
                  mockupWallpaperImage: _mockupWallpaperImage,
                  currentCaption: _currentCaption,
                ),
              ),
              Positioned(
                left: (screenWidth / 2) + (phoneMockupWidth / 2) + spacing,
                top: (screenHeight / 2) - (captionDisplayHeight / 2),
                child: CaptionDisplay(currentCaption: _currentCaption),
              ),
              if (_pickedImage != null)
                Positioned(
                  left: screenWidth / 2 - (imageBaseSize * _imageScale) / 2 + _imageX,
                  top: screenHeight / 2 - (imageBaseSize * _imageScale) / 2 + _imageY,
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
              if (_frameImage != null) ...[
                Builder(builder: (context) {
                  if (_frameRect == null) {
                    final currentScreenWidth = MediaQuery.of(context).size.width;
                    final currentScreenHeight = MediaQuery.of(context).size.height;
                    _frameRect = Rect.fromLTWH(
                      currentScreenWidth / 2 - frameBaseSize / 2,
                      currentScreenHeight / 2 - frameBaseSize / 2,
                      frameBaseSize,
                      frameBaseSize,
                    );
                  }
                  if (_frameRect == null) return const SizedBox.shrink();
                  return TransformableBox(
                    rect: _frameRect!,
                    onChanged: (UITransformResult result, DragUpdateDetails? event) {
                      setState(() {
                        _frameRect = result.rect;
                      });
                    },
                    contentBuilder: (BuildContext context, Rect rect, Flip flip) {
                      return Image.file(
                        _frameImage!,
                        fit: BoxFit.fill,
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
                }),
              ],
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
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                right: _isToolDrawerOpen ? 0 : -200,
                top: 0,
                bottom: 0,
                child: ToolDrawer(
                  pickedImage: _pickedImage,
                  onImageChanged: _onImageChanged,
                  onFrameImageChanged: _onFrameImageChanged,
                  onImagePan: _onImagePan,
                  onImageScale: _onImageScale,
                  currentImageScale: _imageScale,
                  onClose: _closeToolDrawer,
                  onWallpaperChanged: _onWallpaperChanged,
                  onRemoveWallpaper: _removeWallpaper,
                  onMockupWallpaperChanged: _onMockupWallpaperChanged,
                  phoneMockupKey: _phoneMockupKey,
                  appGridKey: _appGridKey,
                  onStartWaiting: _changeBackgroundGradient,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}