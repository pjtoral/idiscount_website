import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idiscount_website/services/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({Key? key}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _authService = AuthService();
  bool _isResending = false;
  bool _isEmailVerified = false;
  Timer? _cooldownTimer;
  Timer? _verificationPollTimer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _isEmailVerified = false;
    _startVerificationPolling();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _verificationPollTimer?.cancel();
    super.dispose();
  }

  void _startVerificationPolling() {
    Future.microtask(() async {
      final isVerified = await _authService.refreshAndCheckEmailVerified();
      if (!mounted) return;
      if (isVerified != _isEmailVerified) {
        setState(() => _isEmailVerified = isVerified);
      }
    });

    _verificationPollTimer?.cancel();
    _verificationPollTimer = Timer.periodic(const Duration(seconds: 5), (
      timer,
    ) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_isEmailVerified) {
        timer.cancel();
        return;
      }

      final isVerified = await _authService.refreshAndCheckEmailVerified();
      if (!mounted) return;
      if (isVerified != _isEmailVerified) {
        setState(() => _isEmailVerified = isVerified);
      }
    });
  }

  void _startResendCooldown([int seconds = 60]) {
    _cooldownTimer?.cancel();
    setState(() => _resendCooldown = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCooldown <= 1) {
        setState(() => _resendCooldown = 0);
        timer.cancel();
      } else {
        setState(() => _resendCooldown--);
      }
    });
  }

  Future<void> _resendVerification() async {
    if (_resendCooldown > 0) return;
    setState(() => _isResending = true);

    try {
      await _authService.resendVerificationEmail();
      _startResendCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification email resent! Check your inbox and spam folder.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend: ${e.toString()}', maxLines: 3),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _handleContinueToRegistration() async {
    if (!_isEmailVerified) return;
    context.go('/register');
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Check Your Email',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'We sent a verification link to:',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Click the link in the email to verify your account.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Resend button
              OutlinedButton(
                onPressed:
                    (_isResending || _resendCooldown > 0)
                        ? null
                        : _resendVerification,
                child:
                    _isResending
                        ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : Text(
                          _resendCooldown > 0
                              ? 'Resend in ${_resendCooldown}s'
                              : 'Resend Verification Email',
                        ),
              ),
              const SizedBox(height: 16),

              // Back to login
              TextButton(
                onPressed: () => context.go('/login'),
                child: const Text('Back to Login'),
              ),
              const SizedBox(height: 16),

              // Continue button (disabled until verified)
              ElevatedButton(
                onPressed:
                    !_isEmailVerified ? null : _handleContinueToRegistration,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(220, 44),
                  maximumSize: const Size(260, 44),
                ),
                child: Text(
                  _isEmailVerified
                      ? 'Continue to Registration'
                      : 'Verify email to continue',
                ),
              ),
              if (!_isEmailVerified) ...[
                const SizedBox(height: 8),
                Text(
                  'Please verify your email to continue',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
