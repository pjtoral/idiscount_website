import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Page Website',
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'IDiscount',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 768 ? 72 : 48,
                fontWeight: FontWeight.w100,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 20),
            Container(width: 100, height: 2, color: Colors.white),
            SizedBox(height: 30),
            Text(
              'Discounts for every student in the Philippines',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 768 ? 24 : 18,
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 50),
            _buildScrollIndicator(),
          ],
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
            constraints: BoxConstraints(maxWidth: 800),
            child: Text(
              'kjfaksjhaksjhfaksjdhsajkdhaksjdhasjda',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width > 768 ? 20 : 16,
                color: Colors.black87,
                height: 1.8,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
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
              height: 200,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildServiceCard('Business One', '10% discount churva'),
                  SizedBox(width: 20),
                  _buildServiceCard('Business Two', '10% discount churva'),
                  SizedBox(width: 20),
                  _buildServiceCard('Business Three', '10% discount churva'),
                  SizedBox(width: 20),
                  _buildServiceCard('Business Three', '10% discount churva'),
                  SizedBox(width: 20),
                  _buildServiceCard('Business Three', '10% discount churva'),
                  SizedBox(width: 20),
                  _buildServiceCard('Business Three', '10% discount churva'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String title, String description) {
    return Container(
      padding: EdgeInsets.all(30),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
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
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: MediaQuery.of(context).size.width > 768 ? 2 : 1,
              childAspectRatio: 1.5,
              mainAxisSpacing: 30,
              crossAxisSpacing: 30,
              children: [
                _buildPortfolioItem('Project One'),
                _buildPortfolioItem('Project Two'),
                _buildPortfolioItem('Project Three'),
                _buildPortfolioItem('Project Four'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioItem(String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_size_select_actual_outlined,
            size: 48,
            color: Colors.grey.shade600,
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: Colors.black87,
              letterSpacing: 1,
            ),
          ),
        ],
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
              'PORTFOLIO',
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
