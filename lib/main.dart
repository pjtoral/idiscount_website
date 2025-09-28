import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

// Import your pages
import 'package:idiscount_website/hero/hero_page.dart';
import 'package:idiscount_website/security_policy/policy.dart';
import 'package:idiscount_website/terms_and_condition/terms.dart';

void main() {
  // Enable clean URLs for Flutter Web
  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDiscount Philippines',
      theme: ThemeData(
        fontFamily: 'Inter',

        // ✅ Backgrounds
        scaffoldBackgroundColor: Colors.white, // Page background always white
        // ✅ AppBar theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // AppBar background white
          elevation: 0, // remove shadow for flat website look
          iconTheme: IconThemeData(color: Colors.black), // icons black
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        // ✅ Color scheme override (so buttons/texts stay dark)
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.grey,
        ).copyWith(
          background: Colors.white,
          onPrimary: Colors.black,
          onSurface: Colors.black,
        ),
      ),
      debugShowCheckedModeBanner: false,

      // Handles all routes (good for web deep linking)
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => HeroPage());
          case '/policy':
            return MaterialPageRoute(builder: (_) => const PolicyPage());
          case '/terms_and_condition':
            return MaterialPageRoute(builder: (_) => const TermsPage());
          default:
            return MaterialPageRoute(
              builder:
                  (_) => const Scaffold(
                    body: Center(
                      child: Text(
                        "404 - Page Not Found",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
            );
        }
      },
    );
  }
}
