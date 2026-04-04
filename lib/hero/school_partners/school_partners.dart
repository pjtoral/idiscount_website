import 'package:flutter/material.dart';

class SchoolPartners extends StatelessWidget {
  const SchoolPartners({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Responsive columns
    int crossAxisCount;
    if (width < 600) {
      crossAxisCount = 2;
    } else if (width < 1024) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 5; // desktop = 5 per row
    }

    final schools = [
      'assets/images/cdu.webp',
      'assets/images/cit.webp',
      'assets/images/cnu.webp',
      'assets/images/iac.webp',
      'assets/images/nu.webp',
      'assets/images/up.webp',
      'assets/images/usc.webp',
      'assets/images/usjr.webp',
      'assets/images/uspf.webp',
      'assets/images/velez.webp',
    ];
    final isDesktop = MediaQuery.of(context).size.width > 768;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
      child: Column(
        children: [
          Text(
            'Partner Schools',
            style: TextStyle(
              fontSize: isDesktop ? 48 : 36,

              color: Color(0xFF111111),
            ),
          ),

          const SizedBox(height: 40),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: schools.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.6,
            ),
            itemBuilder: (context, index) {
              return _SchoolLogoCard(imagePath: schools[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _SchoolLogoCard extends StatelessWidget {
  final String imagePath;

  const _SchoolLogoCard({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: Colors.black.withOpacity(0.05)),
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withOpacity(0.04),
        //     blurRadius: 10,
        //     offset: const Offset(0, 6),
        //   ),
        // ],
      ),
      child: Image.asset(imagePath, fit: BoxFit.contain),
    );
  }
}
