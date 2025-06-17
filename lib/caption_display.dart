import 'package:flutter/material.dart';

class CaptionDisplay extends StatelessWidget {
  final ValueNotifier<String> currentCaption;

  const CaptionDisplay({
    super.key,
    required this.currentCaption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Adjust width as needed
      height: 250, // Adjust height as needed
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blueAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder<String>(
        valueListenable: currentCaption,
        builder: (context, captionText, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Step to follow:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey[700],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SingleChildScrollView( // Allow scrolling if caption is long
                  child: Text(
                    captionText,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}