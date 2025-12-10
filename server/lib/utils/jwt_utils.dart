import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtUtils {
  static String generateToken(String userId, String secret, int expiryHours) {
    final jwt = JWT(
      {
        'userId': userId,
        'iat': DateTime.now().millisecondsSinceEpoch,
      },
      issuer: 'quiz-app',
    );

    return jwt.sign(
      SecretKey(secret),
      expiresIn: Duration(hours: expiryHours),
    );
  }

  static Map<String, dynamic>? verifyToken(String token, String secret) {
    try {
      final jwt = JWT.verify(token, SecretKey(secret));
      return jwt.payload as Map<String, dynamic>;
    } on JWTExpiredException {
      print('JWT expired');
      return null;
    } on JWTException catch (e) {
      print('JWT verification failed: $e');
      return null;
    }
  }
}