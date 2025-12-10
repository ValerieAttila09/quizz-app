import 'package:mongo_dart/mongo_dart.dart';

class QuizHistory {
  final ObjectId? id;
  final ObjectId userId;
  final String difficulty;
  final int score;
  final int totalQuestions;
  final int timeTaken;
  final DateTime completedAt;

  QuizHistory({
    this.id,
    required this.userId,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    DateTime? completedAt,
  }) : completedAt = completedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'difficulty': difficulty,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeTaken': timeTaken,
      'completedAt': completedAt,
    };
  }

  factory QuizHistory.fromMap(Map<String, dynamic> map) {
    return QuizHistory(
      id: map['_id'] as ObjectId?,
      userId: map['userId'] as ObjectId,
      difficulty: map['difficulty'] as String,
      score: map['score'] as int,
      totalQuestions: map['totalQuestions'] as int,
      timeTaken: map['timeTaken'] as int,
      completedAt: map['completedAt'] as DateTime? ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id?.toHexString(),
      'userId': userId.toHexString(),
      'difficulty': difficulty,
      'score': score,
      'totalQuestions': totalQuestions,
      'timeTaken': timeTaken,
      'completedAt': completedAt.toIso8601String(),
    };
  }
}