import 'package:flutter/material.dart';
import 'package:idiscount_website/hero/sections/partners/widgets/partner_card.dart';

/**
 * Things to add:
 *  - Change partners to actual partners pulled from supabase
 *  - Different partners per row
 */
class PartnersSection extends StatelessWidget {
  const PartnersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 425;

    final partners = const [
      PartnerCard(imagePath: 'assets/images/partner1.png'),
      PartnerCard(imagePath: 'assets/images/partner2.png'),
      PartnerCard(imagePath: 'assets/images/partner3.png'),
      PartnerCard(imagePath: 'assets/images/partner4.png'),
      PartnerCard(imagePath: 'assets/images/partner5.png'),
      PartnerCard(imagePath: 'assets/images/partner6.png'),
    ];

    final carouselHeight =
        isDesktop ? screenHeight * 0.35 : screenHeight * 0.30;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.1),
        Text(
          'Partners',
          style: TextStyle(
            fontSize: isDesktop ? 48 : 32,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 30),

        SizedBox(
          height: carouselHeight,
          child: _AutoScrollCarousel(children: partners, reverse: false),
        ),

        SizedBox(
          height: carouselHeight,
          child: _AutoScrollCarousel(children: partners, reverse: true),
        ),
        SizedBox(height: screenHeight * 0.1),
      ],
    );
  }
}

class _AutoScrollCarousel extends StatefulWidget {
  final List<Widget> children;
  final bool reverse;

  const _AutoScrollCarousel({required this.children, this.reverse = false});

  @override
  State<_AutoScrollCarousel> createState() => _AutoScrollCarouselState();
}

class _AutoScrollCarouselState extends State<_AutoScrollCarousel>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();

    _animationController.addListener(() {
      if (!_scrollController.hasClients) return;

      final maxScroll = _scrollController.position.maxScrollExtent;
      final offset = _animationController.value * maxScroll;

      _scrollController.jumpTo(widget.reverse ? maxScroll - offset : offset);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      children: [...widget.children, ...widget.children],
    );
  }
}
