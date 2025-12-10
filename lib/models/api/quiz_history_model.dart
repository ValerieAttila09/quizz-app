class QuizHistoryModel {
  final String id;
  final String userId;
  final String difficulty;
  final int score;
  final int totalQuestions;
  final int timeTaken;
  final DateTime completedAt;

  QuizHistoryModel({
    required this.id,
    required this.userId,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.timeTaken,
    required this.completedAt,
  });

  factory QuizHistoryModel.fromJson(Map<String, dynamic> json) {
    return QuizHistoryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      difficulty: json['difficulty'] as String,
      score: json['score'] as int,
      totalQuestions: json['totalQuestions'] as int,
      timeTaken: json['timeTaken'] as int,
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  String get formattedTime {
    final minutes = timeTaken ~/ 60;
    final seconds = timeTaken % 60;
    return '${minutes}m ${seconds}s';
  }

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(completedAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}