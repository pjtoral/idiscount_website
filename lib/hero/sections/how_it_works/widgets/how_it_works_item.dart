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
      cardWidth = screenWidth * 0.28;
    } else {
      cardWidth = screenWidth * 0.25;
    }

    final cardHeight =
        screenWidth < 600
            ? cardWidth * 1.2
            : screenWidth < 1024
            ? cardWidth * 1.35
            : cardWidth;
    final imageHeightFactor = screenWidth < 1024 ? 0.52 : 0.65;
    final contentPadding = EdgeInsets.fromLTRB(
      screenWidth < 1024 ? 12 : 16,
      screenWidth < 1024 ? 12 : 16,
      screenWidth < 1024 ? 12 : 16,
      screenWidth < 1024 ? 12 : 16,
    );

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
              height: cardHeight * imageHeightFactor,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.black.withOpacity(0.6),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
