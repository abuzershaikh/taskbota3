import 'package:flutter/material.dart';

class AppNameDisplay extends StatelessWidget {
  final ValueNotifier<String> currentAppName;

  const AppNameDisplay({
    super.key,
    required this.currentAppName,
  });

  @override
  Widget build(BuildContext context) {
    // Ye widget app ka naam dikhane ke liye hai.
    return Container(
      width: 400, // Adjust width as needed
      height: 150, // Adjust height as needed
      color: Colors.transparent, // Transparent background
      child: ValueListenableBuilder<String>(
        valueListenable: currentAppName,
        builder: (context, appName, child) {
          return Center(
            child: Text(
              appName, // Display only the app name
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 64, // Large font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 8.0,
                    color: Color.fromARGB(125, 0, 0, 0),
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
