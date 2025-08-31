import 'package:flutter/material.dart';
import 'package:idiscount_website/hero/hero_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IDiscount Philippines',
      theme: ThemeData(primarySwatch: Colors.grey, fontFamily: 'Inter'),
      home: HeroPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
