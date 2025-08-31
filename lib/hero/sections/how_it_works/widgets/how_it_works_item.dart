import 'package:flutter/material.dart';

class HowItWorksItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtext;

  const HowItWorksItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtext,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double cardWidth;
    if (screenWidth < 600) {
      cardWidth = screenWidth * 0.8;
    } else if (screenWidth < 1024) {
      cardWidth = screenWidth * 0.4;
    } else {
      cardWidth = screenWidth * 0.25;
    }

    final cardHeight = cardWidth * 1.2;

    return Container(
      width: cardWidth,
      height: cardHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Image.asset(imagePath, width: 80, height: 80, fit: BoxFit.contain),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              subtext,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
