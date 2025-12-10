import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../utils/jwt_utils.dart';

Middleware authMiddleware(String jwtSecret) {
  return (Handler handler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(
          json.encode({'error': 'Missing or invalid authorization header'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7); // Remove 'Bearer ' prefix
      final payload = JwtUtils.verifyToken(token, jwtSecret);

      if (payload == null) {
        return Response.forbidden(
          json.encode({'error': 'Invalid or expired token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Add userId to request context
      final updatedRequest = request.change(context: {
        'userId': payload['userId'],
      });

      return handler(updatedRequest);
    };
  };
}