import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// pages
import 'package:idiscount_website/hero/hero_page.dart';
import 'package:idiscount_website/security_policy/policy.dart';
import 'package:idiscount_website/terms_and_condition/terms.dart';
import 'package:idiscount_website/pages/login_page.dart';
import 'package:idiscount_website/pages/signup_page.dart';
import 'package:idiscount_website/pages/email_verification_page.dart';
import 'package:idiscount_website/pages/register_page.dart';
import 'package:idiscount_website/pages/dashboard_page.dart';

// theme
import 'package:idiscount_website/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://yfcbtbivhuslzxzqcnve.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlmY2J0Yml2aHVzbHp4enFjbnZlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkyNDcxOTksImV4cCI6MjA4NDgyMzE5OX0.IqtQb9Ci0wxy3gvoIppBsYJHzKaCa4sp2GWfCP1YBAU',
  );

  setUrlStrategy(PathUrlStrategy());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HeroPage()),
        GoRoute(
          path: '/policy',
          builder: (context, state) => const PolicyPage(),
        ),
        GoRoute(
          path: '/terms_and_condition',
          builder: (context, state) => const TermsPage(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupPage(),
        ),
        GoRoute(
          path: '/email-verification',
          builder:
              (context, state) => EmailVerificationPage(
                email: state.uri.queryParameters['email'],
              ),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) {
            final user = Supabase.instance.client.auth.currentUser;
            if (user == null || user.emailConfirmedAt == null) {
              return const EmailVerificationPage();
            }
            return const RegisterPage();
          },
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            final user = Supabase.instance.client.auth.currentUser;
            return DashboardPage(userEmail: user?.email ?? 'user@example.com');
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'IDiscount Philippines',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
