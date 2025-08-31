import 'package:flutter/material.dart';
import 'package:idiscount_website/hero/sections/how_it_works/widgets/how_it_works_item.dart';

class HowItWorks extends StatelessWidget {
  final Color backgroundColor;
  final double sectionHorizontalPadding;
  final double contentMaxWidth;

  const HowItWorks({
    super.key,
    required this.backgroundColor,
    required this.sectionHorizontalPadding,
    required this.contentMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: sectionHorizontalPadding),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 40.0, 0, 40.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'How It Works',
                  style: TextStyle(
                    fontSize: screenWidth > 768 ? 48 : 36,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 60),
                isMobile
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        HowItWorksItem(
                          imagePath: 'assets/images/hiw1.webp',
                          title: 'Fast & Easy',
                          subtext: 'Get things done quickly with our platform.',
                        ),
                        SizedBox(height: 20),
                        HowItWorksItem(
                          imagePath: 'assets/images/hiw2.webp',
                          title: 'Reliable',
                          subtext: 'Always dependable for your needs.',
                        ),
                        SizedBox(height: 20),
                        HowItWorksItem(
                          imagePath: 'assets/images/hiw3.webp',
                          title: 'Secure',
                          subtext: 'Your data is safe with us.',
                        ),
                      ],
                    )
                    : Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 20,
                      runSpacing: 20,
                      children: const [
                        HowItWorksItem(
                          imagePath: 'assets/images/hiw1.webp',
                          title: 'See discounts from nearby businesses.',
                          subtext: '',
                        ),
                        HowItWorksItem(
                          imagePath: 'assets/images/hiw2.webp',
                          title: 'Manually search businesses.',
                          subtext: '',
                        ),
                        HowItWorksItem(
                          imagePath: 'assets/images/hiw3.webp',
                          title: 'Filter discounts by category.',
                          subtext: '',
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
