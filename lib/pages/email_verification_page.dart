import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:idiscount_website/services/app_error_service.dart';
import 'package:idiscount_website/services/auth_service.dart';

class EmailVerificationPage extends StatefulWidget {
  final String? email;

  const EmailVerificationPage({Key? key, this.email}) : super(key: key);

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isResending = false;
  bool _isVerifying = false;
  Timer? _cooldownTimer;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _emailController.text =
        widget.email ?? _authService.getCurrentUser()?.email ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
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
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter your email first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isResending = true);

    try {
      await _authService.sendVerificationCode(email);
      _startResendCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification code resent. Check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppErrorService.toMessage(
                e,
                fallback:
                    'Failed to resend verification code. Please try again.',
              ),
              maxLines: 3,
            ),
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

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final code = _codeController.text.trim();

    setState(() => _isVerifying = true);
    try {
      final response = await _authService.verifyEmailCode(
        email: email,
        code: code,
      );
      await _authService.refreshAndCheckEmailVerified();

      if (mounted) {
        if (response.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Email verified. Please log in again to continue registration.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          context.go('/login');
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully.'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/register');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppErrorService.toMessage(
                e,
                fallback: 'Verification failed. Please try again.',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.mark_email_read_outlined,
                    size: 80,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Enter Verification Code',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A verification code was sent to your email.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: const InputDecoration(
                      labelText: 'Verification Code',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      final code = value?.trim() ?? '';
                      if (code.isEmpty) return 'Code is required';
                      if (code.length < 6 || code.length > 8) {
                        return 'Enter the 6 to 8 digit code';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyCode,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                    ),
                    child:
                        _isVerifying
                            ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Verify Code'),
                  ),
                  const SizedBox(height: 10),
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
                                  : 'Resend Code',
                            ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text('Back to Login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
