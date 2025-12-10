import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../services/database_service.dart';
import '../models/user.dart';

class UserRoutes {
  Router get router {
    final router = Router();

    router.get('/profile', _getProfile);
    router.put('/profile', _updateProfile);

    return router;
  }

  Future<Response> _getProfile(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      
      final userMap = await DatabaseService.users.findOne(
        where.id(ObjectId.fromHexString(userId)),
      );

      if (userMap == null) {
        return Response.notFound(
          json.encode({'error': 'User not found'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final user = User.fromMap(userMap);

      return Response.ok(
        json.encode({'user': user.toJson()}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in get profile: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _updateProfile(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final payload = json.decode(await request.readAsString());

      final updateData = <String, dynamic>{};
      
      if (payload['fullName'] != null) {
        updateData['fullName'] = payload['fullName'];
      }
      
      if (payload['username'] != null) {
        // Check if username is already taken by another user
        final existingUser = await DatabaseService.users.findOne(
          where.eq('username', payload['username']).and(
            where.ne('_id', ObjectId.fromHexString(userId)),
          ),
        );
        
        if (existingUser != null) {
          return Response(
            409,
            body: json.encode({'error': 'Username already taken'}),
            headers: {'Content-Type': 'application/json'},
          );
        }
        
        updateData['username'] = payload['username'];
      }

      if (updateData.isEmpty) {
        return Response.badRequest(
          body: json.encode({'error': 'No fields to update'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      updateData['updatedAt'] = DateTime.now();

      await DatabaseService.users.updateOne(
        where.id(ObjectId.fromHexString(userId)),
        modify.set('fullName', updateData['fullName'] ?? '').set('username', updateData['username'] ?? '').set('updatedAt', updateData['updatedAt']),
      );

      final updatedUserMap = await DatabaseService.users.findOne(
        where.id(ObjectId.fromHexString(userId)),
      );

      final updatedUser = User.fromMap(updatedUserMap!);

      return Response.ok(
        json.encode({
          'message': 'Profile updated successfully',
          'user': updatedUser.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in update profile: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}