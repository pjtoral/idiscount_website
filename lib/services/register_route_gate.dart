import 'dart:math';

class RegisterRouteGate {
  static final Random _random = Random.secure();
  static const int _webSafeNextIntMax = 1 << 30;
  static String? _activeToken;

  static String? get activeToken => _activeToken;

  static String issueToken() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final nonceA = _random.nextInt(_webSafeNextIntMax).toRadixString(16);
    final nonceB = _random.nextInt(_webSafeNextIntMax).toRadixString(16);
    _activeToken = '$now-$nonceA$nonceB';
    return _activeToken!;
  }

  static bool isValid(String? token) {
    return token != null && token.isNotEmpty && token == _activeToken;
  }

  static String buildVerificationPath(String email) {
    final token = issueToken();
    final safe = Uri.encodeComponent(email);
    return '/email-verification?email=$safe&gate=$token';
  }

  static String buildVerificationPathWithToken(String email, String token) {
    final safe = Uri.encodeComponent(email);
    return '/email-verification?email=$safe&gate=$token';
  }

  static String buildRegisterPath() {
    if (_activeToken == null) return '/signup';
    return '/register?gate=${_activeToken!}';
  }

  static void clear() {
    _activeToken = null;
  }
}
