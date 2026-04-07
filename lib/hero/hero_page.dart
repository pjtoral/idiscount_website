import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idiscount_website/hero/school_partners/school_partners.dart';
import 'package:idiscount_website/hero/sections/about/about.dart';
import 'package:idiscount_website/hero/sections/hero_photos/hero_photos.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:idiscount_website/hero/sections/how_it_works/how_it_works.dart';
import 'package:idiscount_website/hero/sections/business_partners/partners.dart';

class HeroPage extends StatefulWidget {
  const HeroPage({Key? key}) : super(key: key);

  @override
  _HeroPageState createState() => _HeroPageState();
}

class _HeroPageState extends State<HeroPage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentSection = 0;
  bool _isAutoScrolling = false;
  late double _heroImageHeight;
  late double _heroMobileImageHeight;
  late double _heroSectionHeight;

  final List<String> _sectionTitles = [
    'Hero',
    'How It Works',
    'About',
    'Partners',
    'Contact',
  ];

  // Consistent padding values
  double get _sectionHorizontalPadding => _isDesktop ? 150 : 40;
  double get _contentMaxWidth => 1200;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _heroImageHeight = MediaQuery.of(context).size.height * 0.9;
          _heroMobileImageHeight = MediaQuery.of(context).size.height * 0.3;
          _heroSectionHeight = MediaQuery.of(context).size.height * 0.7;
        });
      }
    });
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);

    _fadeController.forward();
    // _startAutoScroll();
  }

  void _onScroll() {
    if (_isAutoScrolling) return;

    double offset = _scrollController.offset;
    double screenHeight = MediaQuery.of(context).size.height;
    int newSection = (offset / screenHeight).round();

    newSection = newSection.clamp(0, _sectionTitles.length - 1);

    if (newSection != _currentSection) {
      setState(() {
        _currentSection = newSection;
      });
    }
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        _autoScrollToNext();
      }
    });
  }

  void _autoScrollToNext() {
    if (_isAutoScrolling) return;

    setState(() {
      _isAutoScrolling = true;
      _currentSection = (_currentSection + 1) % _sectionTitles.length;
    });

    double targetOffset = _currentSection * MediaQuery.of(context).size.height;

    _scrollController
        .animateTo(
          targetOffset,
          duration: Duration(milliseconds: 1500),
          curve: Curves.easeInOutCubic,
        )
        .then((_) {
          setState(() {
            _isAutoScrolling = false;
          });

          // Schedule next auto-scroll
          Future.delayed(Duration(seconds: 5), () {
            if (mounted) {
              _autoScrollToNext();
            }
          });
        });
  }

  void _scrollToSection(int index) {
    setState(() {
      _currentSection = index;
      _isAutoScrolling = true;
    });

    double targetOffset = index * MediaQuery.of(context).size.height;
    _scrollController
        .animateTo(
          targetOffset,
          duration: Duration(milliseconds: 1200),
          curve: Curves.easeInOutCubic,
        )
        .then((_) {
          setState(() {
            _isAutoScrolling = false;
          });
        });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  bool get _isDesktop => MediaQuery.of(context).size.width > 800;

  // Consistent section container wrapper
  Widget _buildSectionContainer({
    required Widget child,
    Widget? backgroundImage,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            constraints: BoxConstraints(minHeight: screenHeight),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                  Color.fromARGB(255, 249, 247, 210),
                  Color.fromARGB(255, 187, 207, 177),
                ],
              ),
            ),
          ),

          if (backgroundImage != null)
            Positioned.fill(
              child: Opacity(
                opacity: 0.9, // 👈 adjust visibility
                child: backgroundImage,
              ),
            ),

          Container(
            constraints: BoxConstraints(
              minHeight: screenHeight,
            ), // 👈 outer container
            padding: EdgeInsets.symmetric(
              horizontal: _sectionHorizontalPadding,
              vertical: 60,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _contentMaxWidth),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroSection(),
                PartnersSection(),
                HeroPhotos(),
                HowItWorks(
                  backgroundColor: Colors.white,
                  sectionHorizontalPadding: _sectionHorizontalPadding,
                  contentMaxWidth: _contentMaxWidth,
                ),
                AboutSection(backgroundColor: Colors.white),
                SchoolPartners(),
                _buildContactSection(),
              ],
            ),
          ),
          _buildNavigationDots(),
          _buildFloatingNav(),
          // _buildAuthButtons(),
        ],
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Positioned(
      top: 50,
      right: 40,
      child: Row(
        children: [
          OutlinedButton(
            onPressed: () => context.go('/login'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFFFD54F), width: 2),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Login',
              style: TextStyle(
                color: Color(0xFFFFD54F),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => context.go('/signup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFFD54F),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Register',
              style: TextStyle(
                color: Color(0xFF2D5016),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return SizedBox(
      height: _heroSectionHeight,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: _sectionHorizontalPadding,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: _contentMaxWidth),
                  child:
                      _isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(child: _buildTextContent(isDesktop: true)),
        // Expanded(child: _buildHeroImage(isDesktop: true)),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTextContent(isDesktop: false),
        SizedBox(height: 20),
        // _buildHeroImage(isDesktop: false),
      ],
    );
  }

  Widget _buildTextContent({required bool isDesktop}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.center : CrossAxisAlignment.center,
      children: [
        SizedBox(height: isDesktop ? 0 : 100),
        Text(
          'Empowering Individuals,',
          style: TextStyle(
            fontSize: isDesktop ? 60 : 30,

            color: Color(0xFF2D5016),
            letterSpacing: 2,
          ),
          textAlign: isDesktop ? TextAlign.center : TextAlign.center,
        ),
        Text(
          'Spend Smarter and Save Smarter!',
          style: TextStyle(
            fontSize: isDesktop ? 60 : 30,

            color: Color(0xFF2D5016),
            letterSpacing: 2,
          ),
          textAlign: isDesktop ? TextAlign.center : TextAlign.center,
        ),
        // SizedBox(height: 20),
        // Container(width: 100, height: 2, color: Color(0xFFD4AF37)),
        // SizedBox(height: 30),
        Text(
          'Exclusive discounts, perks, and support designed to grow with you.',
          style: TextStyle(
            fontSize: isDesktop ? 20 : 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2B2B2B),
            letterSpacing: 1,
          ),
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 50 : 30),
        _buildDownloadButtons(isDesktop: isDesktop),
        SizedBox(height: isDesktop ? 50 : 10),
      ],
    );
  }

  Widget _buildDownloadButtons({required bool isDesktop}) {
    return Row(
      mainAxisAlignment:
          isDesktop ? MainAxisAlignment.center : MainAxisAlignment.center,
      children: [
        _buildDownloadButton(
          imagePath: 'assets/images/google_play.webp',
          url:
              'https://play.google.com/store/search?q=idiscount+philippines&c=apps',
          height: isDesktop ? 40.0 : 25.0,
        ),
        SizedBox(width: isDesktop ? 20 : 10),
        _buildDownloadButton(
          imagePath: 'assets/images/apple_store.webp',
          url:
              'https://apps.apple.com/us/app/idiscount-philippines/id6760282556',
          height: isDesktop ? 40.0 : 25.0,
        ),
      ],
    );
  }

  Widget _buildDownloadButton({
    required String imagePath,
    required String url,
    required double height,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => html.window.open(url, '_blank'),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.transparent, // no fill
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFe7e39b), // your soft yellow
              width: 1.5,
            ),
          ),
          child: Image.asset(imagePath, height: height),
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return _buildSectionContainer(
      backgroundImage: Image.asset(
        'assets/images/idiscount_web_bg.webp',
        fit: BoxFit.cover,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Contact Us and Partner Now!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
              color: const Color(0xFF2D5016),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Join us in providing discounts for the essentials that every student needs in the Philippines',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 24 : 14,
              color: const Color(0xFF2D5016),
            ),
          ),

          const SizedBox(height: 40),

          Container(width: 300, height: 2, color: Color(0xFFFFD54F)),

          const SizedBox(height: 60),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 40,
            runSpacing: 20,
            children: [
              _buildContactItem('Email', 'idiscount.philippines@gmail.com'),
              _buildContactItem('Phone', '+639770329562'),
            ],
          ),

          const SizedBox(height: 36),

          const Text(
            'Business owner? Register or login to partner with us.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D5016),
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFD54F), width: 1.5),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                ),
                child: const Text('Login'),
              ),
              ElevatedButton(
                onPressed: () => context.go('/signup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD54F),
                  foregroundColor: const Color(0xFF2D5016),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationDots() {
    return Positioned(
      right: 30,
      top: MediaQuery.of(context).size.height / 2 - 100,
      child: Column(
        children: List.generate(_sectionTitles.length, (index) {
          return GestureDetector(
            onTap: () => _scrollToSection(index),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentSection == index
                        ? Color(0xFFFFD54F)
                        : Colors.white30,
                border: Border.all(
                  color: Color(0xFFFFD54F).withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFloatingNav() {
    if (MediaQuery.of(context).size.width <= 768) {
      return Positioned(
        top: 50,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE7EFE2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'IDiscount',
                style: TextStyle(
                  color: Color(0xFF2D5016),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
              Text(
                '${_currentSection + 1}/${_sectionTitles.length}',
                style: const TextStyle(
                  color: Color(0xFF2D5016),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_sectionTitles.length, (index) {
              return GestureDetector(
                onTap: () => _scrollToSection(index),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    _sectionTitles[index].toUpperCase(),
                    style: TextStyle(
                      color:
                          _currentSection == index
                              ? Color(0xFF2D5016)
                              : Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
