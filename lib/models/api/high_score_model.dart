class HighScoreModel {
  final String id;
  final String userId;
  final String difficulty;
  final int highestScore;
  final int totalQuizzes;
  final double averageScore;
  final DateTime lastUpdated;

  HighScoreModel({
    required this.id,
    required this.userId,
    required this.difficulty,
    required this.highestScore,
    required this.totalQuizzes,
    required this.averageScore,
    required this.lastUpdated,
  });

  factory HighScoreModel.fromJson(Map<String, dynamic> json) {
    return HighScoreModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      difficulty: json['difficulty'] as String,
      highestScore: json['highestScore'] as int,
      totalQuizzes: json['totalQuizzes'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  String get emoji {
    switch (difficulty) {
      case 'Easy':
        return '🟢';
      case 'Medium':
        return '🟡';
      case 'Hard':
        return '🔴';
      default:
        return '⚪';
    }
  }
}