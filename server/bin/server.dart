import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart';
import '../lib/services/database_service.dart';
import '../lib/routes/auth_routes.dart';
import '../lib/routes/user_routes.dart';
import '../lib/routes/quiz_routes.dart';
import '../lib/middleware/auth_middleware.dart';

void main(List<String> args) async {
  // Load environment variables
  final env = DotEnv()..load();

  final mongoUri = env['MONGODB_URI'] ?? '';
  final jwtSecret = env['JWT_SECRET'] ?? 'default-secret-key';
  final jwtExpiryHours = int.tryParse(env['JWT_EXPIRY_HOURS'] ?? '24') ?? 24;
  final port = int.tryParse(env['PORT'] ?? '8080') ?? 8080;

  if (mongoUri.isEmpty) {
    print('❌ Error: MONGODB_URI not found in .env file');
    exit(1);
  }

  // Connect to MongoDB
  try {
    await DatabaseService.connect(mongoUri);
  } catch (e) {
    print('❌ Failed to connect to MongoDB: $e');
    exit(1);
  }

  // Setup routes
  final app = Router();

  // Public routes (no auth required)
  final authRoutes = AuthRoutes(
    jwtSecret: jwtSecret,
    jwtExpiryHours: jwtExpiryHours,
  );
  app.mount('/api/auth', authRoutes.router.call);

  // Protected routes (auth required)
  final userRoutes = UserRoutes();
  final quizRoutes = QuizRoutes();
  
  app.mount(
    '/api/user',
    Pipeline()
        .addMiddleware(authMiddleware(jwtSecret))
        .addHandler(userRoutes.router.call),
  );
  
  app.mount(
    '/api/quiz',
    Pipeline()
        .addMiddleware(authMiddleware(jwtSecret))
        .addHandler(quizRoutes.router.call),
  );

  // Health check endpoint
  app.get('/health', (Request request) {
    return Response.ok('Server is running! 🚀');
  });

  // CORS configuration
  final overrideHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
  };

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders(headers: overrideHeaders))
      .addHandler(app.call);

  // Start server
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  
  print('🚀 Server listening on port ${server.port}');
  print('📍 Health check: http://localhost:${server.port}/health');
  print('🔐 Auth endpoints: http://localhost:${server.port}/api/auth');
  print('👤 User endpoints: http://localhost:${server.port}/api/user');
  print('📝 Quiz endpoints: http://localhost:${server.port}/api/quiz');
}