import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class PinHasher {
  PinHasher._();

  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hash(String pin, String salt) {
    return sha256.convert(utf8.encode('$salt:$pin')).toString();
  }
}