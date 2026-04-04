import 'package:flutter/material.dart';

class PartnerCard extends StatelessWidget {
  final String? imagePath;

  const PartnerCard({super.key, this.imagePath});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double cardWidth;
    if (screenWidth < 480) {
      cardWidth = screenWidth * 0.6;
      cardWidth = cardWidth.clamp(120.0, 240.0);
    } else if (screenWidth < 1024) {
      cardWidth = screenWidth * 0.3;
      cardWidth = cardWidth.clamp(120.0, 230.0);
    } else {
      cardWidth = screenWidth * 0.15;
      cardWidth = cardWidth.clamp(120.0, 270.0);
    }

    final imageSize = cardWidth;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              SizedBox(
                height: imageSize,
                width: imageSize,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(imageSize);
                    },
                  ),
                ),
              )
            else
              _buildPlaceholder(imageSize),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(double size) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.business, size: 48, color: Colors.white54),
    );
  }
}
