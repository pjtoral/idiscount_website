import 'dart:async';

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
import 'package:idiscount_website/services/register_route_gate.dart';
import 'package:idiscount_website/services/business_service.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class _MyAppState extends State<MyApp> {
  late final _AuthRefreshNotifier _authRefreshNotifier;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRefreshNotifier = _AuthRefreshNotifier();
    _router = GoRouter(
      refreshListenable: _authRefreshNotifier,
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
          redirect: (context, state) {
            final gate = state.uri.queryParameters['gate'];
            if (gate == null || gate.isEmpty) {
              return '/signup';
            }
            return null;
          },
          builder:
              (context, state) => EmailVerificationPage(
                email: state.uri.queryParameters['email'],
                gate: state.uri.queryParameters['gate'],
              ),
        ),
        GoRoute(
          path: '/email_verification',
          redirect: (context, state) {
            final gate = state.uri.queryParameters['gate'];
            final email = state.uri.queryParameters['email'] ?? '';
            if (gate == null || gate.isEmpty) {
              return '/signup';
            }
            return RegisterRouteGate.buildVerificationPathWithToken(
              email,
              gate!,
            );
          },
          builder:
              (context, state) => EmailVerificationPage(
                email: state.uri.queryParameters['email'],
                gate: state.uri.queryParameters['gate'],
              ),
        ),
        GoRoute(
          path: '/register',
          redirect: (context, state) async {
            final gateToken = state.uri.queryParameters['gate'];
            final user = Supabase.instance.client.auth.currentUser;
            final hasGate = RegisterRouteGate.isValid(gateToken);

            if (hasGate) {
              if (user == null || user.emailConfirmedAt == null) {
                return '/email-verification?email=&gate=$gateToken';
              }
              return null;
            }

            if (user == null) {
              return '/signup';
            }

            if (user.emailConfirmedAt == null) {
              return '/signup';
            }

            final hasCompletedRegistration =
                await BusinessService().hasCompletedRegistration();

            if (hasCompletedRegistration) {
              return '/dashboard';
            }

            return null;
          },
          builder: (context, state) {
            return const RegisterPage();
          },
        ),
        GoRoute(
          path: '/dashboard',
          redirect: (context, state) async {
            final user = Supabase.instance.client.auth.currentUser;
            if (user == null) {
              return '/signup';
            }

            final hasCompletedRegistration =
                await BusinessService().hasCompletedRegistration();

            if (!hasCompletedRegistration) {
              return '/register';
            }

            return null;
          },
          builder: (context, state) {
            final user = Supabase.instance.client.auth.currentUser;
            return DashboardPage(userEmail: user?.email ?? 'user@example.com');
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _authRefreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'IDiscount Philippines',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
