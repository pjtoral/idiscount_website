import 'package:supabase_flutter/supabase_flutter.dart';

class AppErrorService {
  static String toMessage(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is AuthException) {
      final code = (error.statusCode ?? '').toString();
      final message = error.message.toLowerCase();

      if (code == '400' && message.contains('invalid login credentials')) {
        return 'Incorrect email or password.';
      }
      if (code == '401' || message.contains('invalid jwt')) {
        return 'Your session expired. Please log in again.';
      }
      if (code == '422' && message.contains('already registered')) {
        return 'This email is already registered. Please log in instead.';
      }
      if (code == '429') {
        return 'Too many attempts. Please wait a minute and try again.';
      }
      if (message.contains('email not confirmed')) {
        return 'Please verify your email before logging in.';
      }
      if (message.contains('otp') || message.contains('token')) {
        return 'Invalid or expired verification code. Please request a new code.';
      }

      return error.message;
    }

    if (error is PostgrestException) {
      final message = error.message.toLowerCase();
      if (message.contains('duplicate key') || message.contains('unique')) {
        return 'This record already exists.';
      }
      if (message.contains('foreign key')) {
        return 'Related data is missing or invalid.';
      }
      return error.message;
    }

    if (error is FunctionException) {
      final details = error.details;
      if (details is Map && details['error'] != null) {
        return details['error'].toString();
      }
      if ((error.reasonPhrase ?? '').isNotEmpty) {
        return error.reasonPhrase!;
      }
      return 'Request failed. Please try again.';
    }

    final text = error.toString().replaceFirst('Exception: ', '').trim();
    if (text.startsWith('Business registration failed:')) {
      final clean =
          text.replaceFirst('Business registration failed:', '').trim();
      if (clean.isNotEmpty) return clean;
    }

    return text.isNotEmpty ? text : fallback;
  }
}
