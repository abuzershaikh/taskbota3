import 'package:flutter/material.dart';

class NotificationDrawer extends StatefulWidget {
  const NotificationDrawer({super.key});

  @override
  State<NotificationDrawer> createState() => NotificationDrawerState();
}

class NotificationDrawerState extends State<NotificationDrawer> {
  double _drawerHeight = 0.0; // Current height of the drawer, 0.0 means fully closed
  bool _isDragging = false;
  double _dragStartDy = 0.0; // Y-coordinate where the drag started

  // Constants for drawer heights
  static const double _closedHeight = 0.0;
  static const double _halfOpenHeightFraction = 0.5; // Half of phone height
  static const double _fullOpenHeightFraction = 1.0; // Full phone height
  static const double phoneMockupHeight = 600.0;

  // State for toggles
  bool _wifiEnabled = true;
  bool _bluetoothEnabled = true;
  bool _soundMode = true;
  bool _autoRotate = true;
  bool _airplaneMode = false;
  bool _flashlight = false;
  bool _mobileData = true;
  bool _powerSaving = false;
  bool _location = true;
  bool _mobileHotspot = false;
  bool _linkToWindows = false;
  bool _screenRecorder = false;
  bool _quickShare = true;
  bool _dnd = false;
  bool _eyeComfortShield = false;
  bool _darkMode = false;
  double _brightnessValue = 0.6;

  get currentDrawerHeight => null;


  void openDrawer() {
    setState(() {
      _drawerHeight = phoneMockupHeight * _halfOpenHeightFraction;
    });
  }

  void closeDrawer() {
    setState(() {
      _drawerHeight = _closedHeight;
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragStartDy = details.globalPosition.dy;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    final double delta = details.globalPosition.dy - _dragStartDy;
    double newHeight = _drawerHeight + delta;

    _drawerHeight = newHeight.clamp(
      _closedHeight,
      phoneMockupHeight * _fullOpenHeightFraction,
    );

    _dragStartDy = details.globalPosition.dy;
    setState(() {});
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;

    final double halfPoint = phoneMockupHeight * _halfOpenHeightFraction;
    final double fullPoint = phoneMockupHeight * _fullOpenHeightFraction;

    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! < -500) {
        if (_drawerHeight > halfPoint) {
            _drawerHeight = halfPoint;
        } else {
            closeDrawer();
        }
      } else if (details.primaryVelocity! > 500) {
        if (_drawerHeight < halfPoint) {
            _drawerHeight = halfPoint;
        } else {
            _drawerHeight = fullPoint;
        }
      } else {
        if (_drawerHeight < halfPoint * 0.75) {
            closeDrawer();
        } else if (_drawerHeight < fullPoint * 0.75) {
            _drawerHeight = halfPoint;
        } else {
            _drawerHeight = fullPoint;
        }
      }
    } else {
        if (_drawerHeight < halfPoint * 0.75) {
            closeDrawer();
        } else if (_drawerHeight < fullPoint * 0.75) {
            _drawerHeight = halfPoint;
        } else {
            _drawerHeight = fullPoint;
        }
    }
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: _isDragging ? Duration.zero : const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      top: 0,
      left: 0,
      right: 0,
      height: _drawerHeight,
      child: GestureDetector(
        onTap: _drawerHeight > _closedHeight + 10.0 ? closeDrawer : null,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Container(
          color: _drawerHeight > _closedHeight
              ? Colors.black.withOpacity(0.3 * (_drawerHeight / phoneMockupHeight).clamp(0.0, 1.0))
              : Colors.transparent,
          child: Column(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFFF0F0F0),
                    child: SingleChildScrollView(
                      physics: _drawerHeight >= phoneMockupHeight * _halfOpenHeightFraction
                          ? const AlwaysScrollableScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            _buildTopBar(),
                            const SizedBox(height: 16),
                            _buildLargeButtons(),
                            const SizedBox(height: 24),
                            _buildQuickSettingsGrid(),
                            const SizedBox(height: 24),
                            _buildBrightnessControl(),
                            const SizedBox(height: 16),
                            _buildBottomButtons(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: const Icon(Icons.edit_outlined, color: Colors.black54),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.power_settings_new, color: Colors.black54),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black54),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildLargeButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildLargeButton(
            icon: Icons.wifi,
            title: 'WiFi',
            subtitle: 'callnections', // From image
            isActive: _wifiEnabled,
            onTap: () => setState(() => _wifiEnabled = !_wifiEnabled),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildLargeButton(
            icon: Icons.bluetooth,
            title: 'Bluetooth',
            isActive: _bluetoothEnabled,
            onTap: () => setState(() => _bluetoothEnabled = !_bluetoothEnabled),
          ),
        ),
      ],
    );
  }

  Widget _buildLargeButton({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue[600] : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: isActive ? Colors.white : Colors.black87, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  color: isActive ? Colors.white70 : Colors.grey[700],
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSettingsGrid() {
    final settings = [
      {'icon': Icons.volume_up_outlined, 'label': 'Sound', 'state': _soundMode, 'onTap': () => setState(() => _soundMode = !_soundMode)},
      {'icon': Icons.screen_rotation_outlined, 'label': 'Rotate', 'state': _autoRotate, 'onTap': () => setState(() => _autoRotate = !_autoRotate)},
      {'icon': Icons.airplanemode_active_outlined, 'label': 'Airplane', 'state': _airplaneMode, 'onTap': () => setState(() => _airplaneMode = !_airplaneMode)},
      {'icon': Icons.flashlight_on_outlined, 'label': 'Flashlight', 'state': _flashlight, 'onTap': () => setState(() => _flashlight = !_flashlight)},
      {'icon': Icons.data_usage_outlined, 'label': 'Mobile data', 'state': _mobileData, 'onTap': () => setState(() => _mobileData = !_mobileData)},
      {'icon': Icons.power_settings_new_outlined, 'label': 'Power saving', 'state': _powerSaving, 'onTap': () => setState(() => _powerSaving = !_powerSaving)},
      {'icon': Icons.location_on_outlined, 'label': 'Location', 'state': _location, 'onTap': () => setState(() => _location = !_location)},
      {'icon': Icons.wifi_tethering, 'label': 'Hotspot', 'state': _mobileHotspot, 'onTap': () => setState(() => _mobileHotspot = !_mobileHotspot)},
      {'icon': Icons.devices_outlined, 'label': 'Link to PC', 'state': _linkToWindows, 'onTap': () => setState(() => _linkToWindows = !_linkToWindows)},
      {'icon': Icons.fiber_manual_record_outlined, 'label': 'Recorder', 'state': _screenRecorder, 'onTap': () => setState(() => _screenRecorder = !_screenRecorder)},
      {'icon': Icons.share_outlined, 'label': 'Quick Share', 'state': _quickShare, 'onTap': () => setState(() => _quickShare = !_quickShare)},
      {'icon': Icons.notifications_off_outlined, 'label': 'Do not disturb', 'state': _dnd, 'onTap': () => setState(() => _dnd = !_dnd)},
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) => Expanded(child: _buildGridItem(settings[index]))),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) => Expanded(child: _buildGridItem(settings[index + 4]))),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) => Expanded(child: _buildGridItem(settings[index + 8]))),
        ),
      ],
    );
  }

  Widget _buildGridItem(Map<String, dynamic> item) {
    bool isActive = item['state'];
    return GestureDetector(
      onTap: item['onTap'],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue[600] : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Icon(
              item['icon'],
              color: isActive ? Colors.white : Colors.black87,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: Text(
              item['label'],
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrightnessControl() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Slider(
            value: _brightnessValue,
            onChanged: (value) => setState(() => _brightnessValue = value),
            activeColor: Colors.blue[700],
            inactiveColor: Colors.grey[400],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBrightnessOptionButton(
                Icons.nightlight_outlined,
                'Eye comfort shield',
                _eyeComfortShield,
                () => setState(() => _eyeComfortShield = !_eyeComfortShield)
              ),
              const SizedBox(width: 8),
              _buildBrightnessOptionButton(
                Icons.dark_mode_outlined,
                'Dark mode',
                _darkMode,
                () => setState(() => _darkMode = !_darkMode)
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBrightnessOptionButton(IconData icon, String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20, color: isActive ? Colors.blue[800] : Colors.black87),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      text,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isActive ? Colors.blue[800] : Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
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

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTextButton('Smart View', false, () {}),
          _buildTextButton('Device control', false, () {}),
        ],
      ),
    );
  }
  
  Widget _buildTextButton(String text, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.blue[800] : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}