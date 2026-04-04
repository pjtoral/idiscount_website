import 'package:flutter/material.dart';
import 'package:idiscount_website/hero/sections/business_partners/widgets/partner_card.dart';

class PartnersSection extends StatelessWidget {
  const PartnersSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 425;

    final partners = const [
      _PartnerText("Wisechoice Supplements"),
      _PartnerText("TUF Barbershop"),
      _PartnerText("Hola Coffee"),
      _PartnerText("Handuraw Pizza"),
      _PartnerText("Genie Cakes"),
      _PartnerText("Cloudkart"),
      _PartnerText("Lasagnyum"),
    ];

    final carouselHeight = isDesktop ? screenHeight * 0.1 : screenHeight * 0.10;

    return Container(
      width: double.infinity,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            height: carouselHeight,
            child: _AutoScrollCarousel(children: partners, reverse: false),
          ),
        ],
      ),
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

class _PartnerText extends StatelessWidget {
  final String text;

  const _PartnerText(this.text);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 425;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: isDesktop ? 20 : 14, // slightly bigger
            fontWeight: FontWeight.w600, // bold but not too heavy
            color: Colors.black.withOpacity(0.5), // subtle transparency
            letterSpacing: 0.5, // gives it that premium spacing
          ),
        ),
      ),
    );
  }
}
