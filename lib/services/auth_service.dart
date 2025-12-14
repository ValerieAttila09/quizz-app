import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:quiz_app/models/api/user_model.dart';

class AuthService {
  Future<String> _loadJsonData() async {
    return await rootBundle.loadString('database.json');
  }

  Future<List<User>> _getUsers() async {
    final jsonString = await _loadJsonData();
    final jsonResponse = json.decode(jsonString);
    final users = (jsonResponse['users'] as List)
        .map((user) => User.fromJson(user))
        .toList();
    return users;
  }

  Future<User?> login(String username, String password) async {
    final users = await _getUsers();
    try {
      final user = users.firstWhere(
          (user) => user.username == username && user.password == password);
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<bool> register(String username, String password) async {
    final users = await _getUsers();
    if (users.any((user) => user.username == username)) {
      return false; // Username already exists
    }

    // Note: In a real app, you would not store the database.json in assets
    // and you would properly update the file.
    // This is a simplified example.
    users.add(User(username: username, password: password));

    // This part is tricky because we can't write back to the assets folder.
    // In a real application, you would have a backend service to handle this.
    // For this example, registration will appear to work but won't be persistent
    // across app restarts because we can't modify the asset file.

    return true;
  }
}
