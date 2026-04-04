import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  final Color backgroundColor;

  const AboutSection({super.key, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 1.15,
      width: double.infinity,
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: Alignment.topCenter,
      //     end: Alignment.bottomCenter,
      //     colors: [Colors.white, Color(0xFFeae594), Color(0xFFB0CBA1)],
      //   ),
      // ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50),
            Text(
              'Supported By',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFeaturedItem(imagePath: 'assets/images/fi1.webp'),
                _buildFeaturedItem(imagePath: 'assets/images/fi3.webp'),
                _buildFeaturedItem(imagePath: 'assets/images/fi5.webp'),
                _buildFeaturedItem(imagePath: 'assets/images/fi4.webp'),
                _buildFeaturedItem(imagePath: 'assets/images/fi2.webp'),
              ],
            ),
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/about_us_1.webp',
                  height: 500,
                  fit: BoxFit.contain,
                ),
                _buildAboutBox1(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutBox1(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: isDesktop ? 48 : 36,
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),

          Container(
            height: isDesktop ? 300 : null, // flexible height on mobile
            padding: const EdgeInsets.only(top: 30),

            child: Text(
              "IDiscount was created primarily to offer students from University of San Carlos discounts with partnered stores. Today, through strategic partnerships with businesses, iDiscount Philippines aims to ease financial burdens by making products and services more affordable for the student and alumni community of partnered schools outside of USC.",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: isDesktop ? 18 : 16,
                color: Colors.black87,
                height: 1.8,
                letterSpacing: 0.5,
              ),
            ),
          ),

          FilledButton(
            onPressed: () {},
            style: ButtonStyle(
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // adjust this
                ),
              ),
            ),
            child: SizedBox(
              height: 50,
              width: 100,
              child: Center(child: const Text('Learn more')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedItem({String? imagePath}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                height: 120,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_size_select_actual_outlined,
                      size: 48,
                      color: Colors.grey.shade600,
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
