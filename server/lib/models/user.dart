import 'package:mongo_dart/mongo_dart.dart';

class User {
  final ObjectId? id;
  final String email;
  final String username;
  final String password;
  final String fullName;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.email,
    required this.username,
    required this.password,
    required this.fullName,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'email': email,
      'username': username,
      'password': password,
      'fullName': fullName,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] as ObjectId?,
      email: map['email'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      fullName: map['fullName'] as String,
      createdAt: map['createdAt'] as DateTime? ?? DateTime.now(),
      updatedAt: map['updatedAt'] as DateTime? ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id?.toHexString(),
      'email': email,
      'username': username,
      'fullName': fullName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}