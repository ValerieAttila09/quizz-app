import 'package:mongo_dart/mongo_dart.dart';

class HighScore {
  final ObjectId? id;
  final ObjectId userId;
  final String difficulty;
  final int highestScore;
  final int totalQuizzes;
  final double averageScore;
  final DateTime lastUpdated;

  HighScore({
    this.id,
    required this.userId,
    required this.difficulty,
    required this.highestScore,
    required this.totalQuizzes,
    required this.averageScore,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'difficulty': difficulty,
      'highestScore': highestScore,
      'totalQuizzes': totalQuizzes,
      'averageScore': averageScore,
      'lastUpdated': lastUpdated,
    };
  }

  factory HighScore.fromMap(Map<String, dynamic> map) {
    return HighScore(
      id: map['_id'] as ObjectId?,
      userId: map['userId'] as ObjectId,
      difficulty: map['difficulty'] as String,
      highestScore: map['highestScore'] as int,
      totalQuizzes: map['totalQuizzes'] as int,
      averageScore: (map['averageScore'] as num).toDouble(),
      lastUpdated: map['lastUpdated'] as DateTime? ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id?.toHexString(),
      'userId': userId.toHexString(),
      'difficulty': difficulty,
      'highestScore': highestScore,
      'totalQuizzes': totalQuizzes,
      'averageScore': averageScore,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }
}