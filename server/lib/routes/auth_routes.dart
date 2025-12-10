import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../services/database_service.dart';
import '../models/user.dart';
import '../utils/password_utils.dart';
import '../utils/jwt_utils.dart';

class AuthRoutes {
  final String jwtSecret;
  final int jwtExpiryHours;

  AuthRoutes({required this.jwtSecret, required this.jwtExpiryHours});

  Router get router {
    final router = Router();

    router.post('/register', _register);
    router.post('/login', _login);
    router.get('/verify', _verifyToken);

    return router;
  }

  Future<Response> _register(Request request) async {
    try {
      final payload = json.decode(await request.readAsString());
      
      // Validate required fields
      if (payload['email'] == null ||
          payload['username'] == null ||
          payload['password'] == null ||
          payload['fullName'] == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Missing required fields'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Validate email format
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(payload['email'])) {
        return Response.badRequest(
          body: json.encode({'error': 'Invalid email format'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Validate password length
      if (payload['password'].length < 6) {
        return Response.badRequest(
          body: json.encode({'error': 'Password must be at least 6 characters'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Check if user already exists
      final existingUser = await DatabaseService.users.findOne(
        where.eq('email', payload['email']).or(where.eq('username', payload['username'])),
      );

      if (existingUser != null) {
        return Response(
          409,
          body: json.encode({'error': 'Email or username already exists'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Hash password
      final hashedPassword = PasswordUtils.hashPassword(payload['password']);

      // Create user
      final user = User(
        email: payload['email'],
        username: payload['username'],
        password: hashedPassword,
        fullName: payload['fullName'],
      );

      final result = await DatabaseService.users.insertOne(user.toMap());
      final userId = result.id.toHexString();

      // Generate JWT token
      final token = JwtUtils.generateToken(userId, jwtSecret, jwtExpiryHours);

      return Response.ok(
        json.encode({
          'message': 'User registered successfully',
          'token': token,
          'user': {
            'id': userId,
            'email': user.email,
            'username': user.username,
            'fullName': user.fullName,
          },
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in register: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _login(Request request) async {
    try {
      final payload = json.decode(await request.readAsString());

      if (payload['email'] == null || payload['password'] == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Email and password are required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final userMap = await DatabaseService.users.findOne(
        where.eq('email', payload['email']),
      );

      if (userMap == null) {
        return Response.forbidden(
          json.encode({'error': 'Invalid email or password'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = User.fromMap(userMap);

      if (!PasswordUtils.verifyPassword(payload['password'], user.password)) {
        return Response.forbidden(
          json.encode({'error': 'Invalid email or password'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Generate JWT token
      final token = JwtUtils.generateToken(
        user.id!.toHexString(),
        jwtSecret,
        jwtExpiryHours,
      );

      return Response.ok(
        json.encode({
          'message': 'Login successful',
          'token': token,
          'user': user.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in login: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _verifyToken(Request request) async {
    try {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.forbidden(
          json.encode({'error': 'Missing or invalid authorization header'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7);
      final payload = JwtUtils.verifyToken(token, jwtSecret);

      if (payload == null) {
        return Response.forbidden(
          json.encode({'error': 'Invalid or expired token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      return Response.ok(
        json.encode({
          'valid': true,
          'userId': payload['userId'],
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in verify token: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}