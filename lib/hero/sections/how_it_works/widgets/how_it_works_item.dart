import 'package:flutter/material.dart';

class HowItWorksItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const HowItWorksItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
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

    final cardHeight = cardWidth * 1;

    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              imagePath,
              height: cardHeight * 0.65,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black.withOpacity(0.6),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
