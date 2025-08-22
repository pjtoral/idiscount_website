import 'package:flutter/material.dart';
import 'dart:html' as html;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDiscount Philippines',
      theme: ThemeData(primarySwatch: Colors.grey, fontFamily: 'Inter'),
      home: OnePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OnePage extends StatefulWidget {
  @override
  _OnePageState createState() => _OnePageState();
}

class _OnePageState extends State<OnePage> with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _currentSection = 0;
  bool _isAutoScrolling = false;

  final List<String> _sectionTitles = [
    'Hero',
    'About',
    'Partners',
    'How It Works',
    'Featured In',
    'Contact',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Add scroll listener to update current section
    _scrollController.addListener(_onScroll);

    _fadeController.forward();
    _startAutoScroll();
  }

  void _onScroll() {
    if (_isAutoScrolling) return; // Don't update during auto-scroll

    double offset = _scrollController.offset;
    double screenHeight = MediaQuery.of(context).size.height;
    int newSection = (offset / screenHeight).round();

    // Clamp to valid section range
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildHeroSection(),
                _buildAboutSection(),
                _buildServicesSection(),
                _buildPortfolioSection(),
                _buildFeaturedSection(),
                _buildContactSection(),
              ],
            ),
          ),
          _buildNavigationDots(),
          _buildFloatingNav(),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black, Colors.grey.shade900],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: _isDesktop ? 150 : 40),
          child: _isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  bool get _isDesktop => MediaQuery.of(context).size.width > 800;

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
            fontWeight: FontWeight.w100,
            color: Colors.white,
            letterSpacing: 4,
          ),
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
        ),
        SizedBox(height: 20),
        Container(width: 100, height: 2, color: Colors.white),
        SizedBox(height: 30),
        Text(
          'Discounts for every student in the Philippines',
          style: TextStyle(
            fontSize: isDesktop ? 24 : 18,
            color: Colors.white70,
            letterSpacing: 2,
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
          imagePath: 'assets/images/google_play.png',
          url: 'https://play.google.com/store',
          height: isDesktop ? 60.0 : 50.0,
        ),
        SizedBox(width: isDesktop ? 30 : 20),
        _buildDownloadButton(
          imagePath: 'assets/images/apple_store.png',
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
            color: Colors.white,
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
    if (isDesktop) {
      return Center(
        child: Image.asset(
          'assets/images/idiscount_mvp.png',
          fit: BoxFit.contain,
          height: MediaQuery.of(context).size.height * 0.9,
        ),
      );
    }

    return Flexible(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.3,
        ),
        child: Image.asset(
          'assets/images/idiscount_mvp.png',
          fit: BoxFit.contain,
        ),
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

  Widget _buildAboutSection() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'About',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
              fontWeight: FontWeight.w300,
              color: Colors.black,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 40),
          Container(width: 80, height: 2, color: Colors.black),
          SizedBox(height: 40),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1200),
            child:
                MediaQuery.of(context).size.width > 800
                    ? Row(
                      children: [
                        Expanded(child: _buildAboutBox1()),
                        SizedBox(width: 30),
                        Expanded(child: _buildAboutBox2()),
                      ],
                    )
                    : Column(
                      children: [
                        _buildAboutBox1(),
                        SizedBox(height: 30),
                        _buildAboutBox2(),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutBox1() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
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
      child: Center(
        child: Text(
          "IDiscount was created primarily to offer students from USC discounts with partnered stores. Through strategic partnerships with businesses, iDiscount aims to ease these burdens by making products and services more affordable for the student community.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: Colors.black87,
            height: 1.8,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAboutBox2() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
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
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "History & Motto",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 15),
            Text(
              "It was first established in 2005 to alleviate the financial challenges faced by every Carolinian. With that goal in mind, it has been actively delivering the same service to the Carolinian community for 20 years now. With USC IDiscount, you can now MAKE YOUR MONEY COUNT.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
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

  Widget _buildServicesSection() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.grey.shade900,
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Partners',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 60),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: SizedBox(
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
            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioSection() {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 40),
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
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPortfolioItem(imagePath: 'assets/images/feature1.png'),
                SizedBox(width: 20),
                _buildPortfolioItem(imagePath: 'assets/images/feature2.png'),
                SizedBox(width: 20),
                _buildPortfolioItem(imagePath: 'assets/images/feature3.png'),
              ],
            ),
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
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.grey.shade100,
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Featured in',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
              fontWeight: FontWeight.w300,
              color: Colors.black,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 60),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 1000),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFeaturedItem(imagePath: 'assets/images/fi1.jpg'),
                SizedBox(width: 20),
                _buildFeaturedItem(imagePath: 'assets/images/fi2.jpg'),
                SizedBox(width: 20),
                _buildFeaturedItem(imagePath: 'assets/images/fi3.jpg'),
              ],
            ),
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
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.black,
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Contact',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width > 768 ? 48 : 36,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
          SizedBox(height: 40),
          Container(width: 80, height: 2, color: Colors.white),
          SizedBox(height: 60),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                Text(
                  'Let\'s work together',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
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
            color: Colors.white54,
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
                color: _currentSection == index ? Colors.white : Colors.white30,
                border: Border.all(color: Colors.white30, width: 1),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'IDiscount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                letterSpacing: 2,
              ),
            ),
            Text(
              '${_currentSection + 1}/${_sectionTitles.length}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
          ],
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
            color: Colors.black54,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24, width: 1),
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
                              ? Colors.white
                              : Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 1.5,
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
