import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idiscount_website/hero/sections/about/about.dart';
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:idiscount_website/hero/sections/how_it_works/how_it_works.dart';
import 'package:idiscount_website/hero/sections/partners/partners.dart';

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
    'About',
    'Partners',
    'How It Works',
    'Featured In',
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
          _heroSectionHeight = MediaQuery.of(context).size.height;
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
    required Color backgroundColor,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      constraints: BoxConstraints(minHeight: screenHeight),
      width: double.infinity,
      color: backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: _sectionHorizontalPadding),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _contentMaxWidth),
          child: child,
        ),
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
                AboutSection(backgroundColor: Colors.white),
                PartnersSection(),
                HowItWorks(
                  backgroundColor: Colors.white,
                  sectionHorizontalPadding: _sectionHorizontalPadding,
                  contentMaxWidth: _contentMaxWidth,
                ),
                _buildFeaturedSection(),
                _buildContactSection(),
              ],
            ),
          ),
          _buildNavigationDots(),
          _buildFloatingNav(),
          _buildAuthButtons(),
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
    return Container(
      height: _heroSectionHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF9FBF7), Color(0xFFFFFFFF)],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _sectionHorizontalPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: _contentMaxWidth),
              child: _isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(child: _buildTextContent(isDesktop: true)),
        Expanded(child: _buildHeroImage(isDesktop: true)),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTextContent(isDesktop: false),
        SizedBox(height: 20),
        _buildHeroImage(isDesktop: false),
      ],
    );
  }

  Widget _buildTextContent({required bool isDesktop}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          'IDiscount',
          style: TextStyle(
            fontSize: isDesktop ? 72 : 48,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D5016),
            letterSpacing: 2,
          ),
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: 20),
        Container(width: 100, height: 2, color: Color(0xFFD4AF37)),
        SizedBox(height: 30),
        Text(
          'Discounts for every student in the Philippines',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 18,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2B2B2B),
            letterSpacing: 1,
          ),
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: isDesktop ? 50 : 30),
        _buildDownloadButtons(isDesktop: isDesktop),
      ],
    );
  }

  Widget _buildDownloadButtons({required bool isDesktop}) {
    return Row(
      mainAxisAlignment:
          isDesktop ? MainAxisAlignment.start : MainAxisAlignment.center,
      children: [
        _buildDownloadButton(
          imagePath: 'assets/images/google_play.webp',
          url: 'https://play.google.com/store',
          height: isDesktop ? 60.0 : 50.0,
        ),
        SizedBox(width: isDesktop ? 30 : 20),
        _buildDownloadButton(
          imagePath: 'assets/images/apple_store.webp',
          url: 'https://apps.apple.com',
          height: isDesktop ? 60.0 : 50.0,
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
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xFFFFD54F),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Image.asset(imagePath, height: height),
        ),
      ),
    );
  }

  Widget _buildHeroImage({required bool isDesktop}) {
    final String imagePath = 'assets/images/idiscount_mvp.webp';
    final String fallbackPath = 'assets/images/idiscount_mvp.png';
    final imageHeight = isDesktop ? _heroImageHeight : _heroMobileImageHeight;

    if (isDesktop) {
      return SizedBox(
        height: imageHeight,
        width: imageHeight * 0.9,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              fallbackPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: imageHeight,
                  child: Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: Colors.white30,
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return SizedBox(
      height: imageHeight,
      width: imageHeight * 0.8,
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Image.asset(
            fallbackPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: imageHeight,
                child: Icon(
                  Icons.image_not_supported,
                  size: 50,
                  color: Colors.white30,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildScrollIndicator() {
    return Column(
      children: [
        Text(
          'SCROLL',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 10),
        Container(width: 2, height: 30, color: Colors.white54),
      ],
    );
  }

  Widget _buildServicesSection() {
    return _buildSectionContainer(
      backgroundColor: Color(0xFF558B2F),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Partners',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 60),
          SizedBox(
            height: 300,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildServiceCard(
                  'up to 35% discount',
                  imagePath: 'assets/images/partner1.png',
                ),
                SizedBox(width: 20),
                _buildServiceCard(
                  'up to 15% discount',
                  imagePath: 'assets/images/partner2.png',
                ),
                SizedBox(width: 20),
                _buildServiceCard(
                  '10% discount',
                  imagePath: 'assets/images/partner3.png',
                ),
                SizedBox(width: 20),
                _buildServiceCard(
                  '10% discount',
                  imagePath: 'assets/images/partner4.png',
                ),
                SizedBox(width: 20),
                _buildServiceCard(
                  '5% discount',
                  imagePath: 'assets/images/partner5.png',
                ),
                SizedBox(width: 20),
                _buildServiceCard(
                  '20% discount',
                  imagePath: 'assets/images/partner6.png',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String description, {String? imagePath}) {
    return Container(
      width: 200,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imagePath != null)
            Container(
              height: 200,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  height: 100,
                  width: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 100,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.business,
                        size: 48,
                        color: Colors.white54,
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Container(
              height: 100,
              width: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.business, size: 48, color: Colors.white54),
            ),
          SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection() {
    return _buildSectionContainer(
      backgroundColor: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
              fontWeight: FontWeight.w300,
              color: Colors.black,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPortfolioItem(imagePath: 'assets/images/feature1.png'),
              SizedBox(width: 20),
              _buildPortfolioItem(imagePath: 'assets/images/feature2.png'),
              SizedBox(width: 20),
              _buildPortfolioItem(imagePath: 'assets/images/feature3.png'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem({String? imagePath}) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imagePath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 300,
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
              )
            else
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_size_select_actual_outlined,
                  size: 48,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return _buildSectionContainer(
      backgroundColor: Color(0xFFFFF8E1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Featured in',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D5016),
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeaturedItem(imagePath: 'assets/images/fi1.webp'),
              SizedBox(width: 20),
              _buildFeaturedItem(imagePath: 'assets/images/fi2.webp'),
              SizedBox(width: 20),
              _buildFeaturedItem(imagePath: 'assets/images/fi3.webp'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedItem({String? imagePath}) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
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
              )
            else
              Container(
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    return _buildSectionContainer(
      backgroundColor: Color(0xFF2D5016),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Contact',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 40),
          Container(width: 80, height: 2, color: Color(0xFFFFD54F)),
          SizedBox(height: 60),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Text(
                  'Let\'s work together',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFD54F),
                    letterSpacing: 1,
                  ),
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildContactItem('Email', 'hello@idiscount.app'),
                    _buildContactItem('Phone', '+639770329562'),
                  ],
                ),
              ],
            ),
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
            color: Color(0xFFFFD54F).withOpacity(0.8),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
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
            color: Color(0xFF2D5016).withOpacity(0.95),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Color(0xFFFFD54F).withOpacity(0.6),
              width: 2,
            ),
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
                              ? Color(0xFFFFD54F)
                              : Colors.white.withOpacity(0.9),
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
