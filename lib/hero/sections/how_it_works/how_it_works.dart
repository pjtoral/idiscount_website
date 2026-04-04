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
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [Colors.white, Color(0xFFeae594), Color(0xFFB0CBA1)],
      //   ),
      // ),
      padding: EdgeInsets.symmetric(horizontal: sectionHorizontalPadding),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 80.0, 0, 40.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: contentMaxWidth),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "It's free. So, how do it work?",
                  style: TextStyle(
                    fontSize: screenWidth > 768 ? 48 : 36,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 60),
                isMobile
                    ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        HowItWorksItem(
                          imagePath: 'assets/images/app_3.webp',
                          title: 'Step 1 - Browse Businesses',
                          description:
                              'Explore exclusive deals from partner businesses you need at the moment. We have categories from food to services!',
                        ),
                        SizedBox(height: 10),
                        HowItWorksItem(
                          imagePath: 'assets/images/app_2.webp',
                          title: 'Step 2 - Choose a Discount',
                          description:
                              'Discounts range from percentages off to buy one get one deals. Select the discount that best fits you at the moment!',
                        ),
                        SizedBox(height: 10),
                        HowItWorksItem(
                          imagePath: 'assets/images/app_1.webp',
                          title: 'Step 3 - Check Out!',
                          description:
                              'Claim the discount instore or online depending on the business capabilities. You are given the flexibility to choose!',
                        ),
                      ],
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        HowItWorksItem(
                          imagePath: 'assets/images/app_3.webp',
                          title: 'Step 1 - Browse Businesses',
                          description:
                              'Explore exclusive deals from partner businesses you need at the moment. We have categories from food to services!',
                        ),
                        SizedBox(width: 10),
                        HowItWorksItem(
                          imagePath: 'assets/images/app_2.webp',
                          title: 'Step 2 - Choose a Discount',
                          description:
                              'Discounts range from percentages off to buy one get one deals. Select the discount that best fits you at the moment!',
                        ),
                        SizedBox(width: 10),
                        HowItWorksItem(
                          imagePath: 'assets/images/app_1.webp',
                          title: 'Step 3 - Check Out!',
                          description:
                              'Claim the discount instore or online depending on the business capabilities. You are given the flexibility to choose!',
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
