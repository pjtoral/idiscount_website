import 'dart:math';

class RegisterRouteGate {
  static final Random _random = Random.secure();
  static String? _activeToken;

  static String issueToken() {
    final now = DateTime.now().microsecondsSinceEpoch;
    final nonce = _random.nextInt(1 << 32).toRadixString(16);
    _activeToken = '$now-$nonce';
    return _activeToken!;
  }

  static bool isValid(String? token) {
    return token != null && token.isNotEmpty && token == _activeToken;
  }

  static String buildRegisterPath() {
    final token = issueToken();
    return '/register?gate=$token';
  }

  static void clear() {
    _activeToken = null;
  }
}
