import 'package:flutter/material.dart';

class AboutSection extends StatelessWidget {
  final Color backgroundColor;

  const AboutSection({super.key, this.backgroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'About',
                style: TextStyle(
                  fontSize: isDesktop ? 48 : 36,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 40),
              Container(width: 80, height: 2, color: Colors.black),
              const SizedBox(height: 40),

              // Responsive layout
              isDesktop
                  ? Row(
                    children: [
                      Expanded(child: _buildAboutBox1(context)),
                      const SizedBox(width: 30),
                      Expanded(child: _buildAboutBox2(context)),
                    ],
                  )
                  : Column(
                    children: [
                      _buildAboutBox1(context),
                      const SizedBox(height: 30),
                      _buildAboutBox2(context),
                    ],
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutBox1(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      height: isDesktop ? 300 : null, // flexible height on mobile
      padding: const EdgeInsets.all(30),
      decoration: _boxDecoration(),
      child: Center(
        child: Text(
          "IDiscount was created primarily to offer students from USC discounts with partnered stores. Through strategic partnerships with businesses, iDiscount aims to ease these burdens by making products and services more affordable for the student community.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isDesktop ? 18 : 16,
            color: Colors.black87,
            height: 1.8,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutBox2(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 768;

    return Container(
      height: isDesktop ? 300 : null, // flexible height on mobile
      padding: const EdgeInsets.all(30),
      decoration: _boxDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "History & Motto",
              style: TextStyle(
                fontSize: isDesktop ? 20 : 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "It was first established in 2005 to alleviate the financial challenges faced by every Carolinian. With that goal in mind, it has been actively delivering the same service to the Carolinian community for 20 years now. With USC IDiscount, you can now MAKE YOUR MONEY COUNT.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 16 : 14,
                color: Colors.black87,
                height: 1.8,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade50,
      border: Border.all(color: Colors.grey.shade300, width: 1),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
