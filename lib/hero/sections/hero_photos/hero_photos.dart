import 'package:flutter/widgets.dart';

/// {@template hero_photos}
/// HeroPhotos widget.
/// {@endtemplate}
class HeroPhotos extends StatelessWidget {
  /// {@macro hero_photos}
  const HeroPhotos({
    super.key, // ignore: unused_element_parameter
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final isMobile = width < 600;
        final isTablet = width >= 600 && width < 1024;
        final isDesktop = width >= 1024;

        // Base size adjusts per screen
        final baseSize =
            isMobile
                ? width * 0.35
                : isTablet
                ? width * 0.22
                : width * 0.12;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/hero_1.webp',
                width: baseSize * 1.6,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 15),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/hero_2.webp',
                height: baseSize * 1.7,
                fit: BoxFit.contain,
              ),
            ),
            if (isDesktop) ...[
              SizedBox(width: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/hero_4.webp',
                  width: baseSize * 1.2,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/hero_3.webp',
                  height: baseSize * 1.4,

                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/hero_5.webp',
                  height: baseSize * 1,
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: 15),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'assets/images/hero_6.webp',
                  width: baseSize * 1.6,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
