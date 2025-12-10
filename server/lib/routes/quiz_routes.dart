import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:mongo_dart/mongo_dart.dart';
import '../services/database_service.dart';
import '../models/quiz_history.dart';
import '../models/high_score.dart';

class QuizRoutes {
  Router get router {
    final router = Router();

    router.post('/submit', _submitQuiz);
    router.get('/history', _getHistory);
    router.get('/stats', _getStats);

    return router;
  }

  Future<Response> _submitQuiz(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final payload = json.decode(await request.readAsString());

      if (payload['difficulty'] == null ||
          payload['score'] == null ||
          payload['totalQuestions'] == null ||
          payload['timeTaken'] == null) {
        return Response.badRequest(
          body: json.encode({'error': 'Missing required fields'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final userObjectId = ObjectId.fromHexString(userId);

      // Save quiz history
      final quizHistory = QuizHistory(
        userId: userObjectId,
        difficulty: payload['difficulty'],
        score: payload['score'],
        totalQuestions: payload['totalQuestions'],
        timeTaken: payload['timeTaken'],
      );

      await DatabaseService.quizHistory.insertOne(quizHistory.toMap());

      // Update high scores
      await _updateHighScores(
        userObjectId,
        payload['difficulty'],
        payload['score'],
      );

      return Response.ok(
        json.encode({
          'message': 'Quiz submitted successfully',
          'quizHistory': quizHistory.toJson(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in submit quiz: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<void> _updateHighScores(
    ObjectId userId,
    String difficulty,
    int score,
  ) async {
    final existingScore = await DatabaseService.highScores.findOne(
      where.eq('userId', userId).eq('difficulty', difficulty),
    );

    if (existingScore == null) {
      // Create new high score entry
      final highScore = HighScore(
        userId: userId,
        difficulty: difficulty,
        highestScore: score,
        totalQuizzes: 1,
        averageScore: score.toDouble(),
      );
      await DatabaseService.highScores.insertOne(highScore.toMap());
    } else {
      final currentHighest = existingScore['highestScore'] as int;
      final totalQuizzes = existingScore['totalQuizzes'] as int;
      final currentAverage = (existingScore['averageScore'] as num).toDouble();

      final newHighest = score > currentHighest ? score : currentHighest;
      final newTotal = totalQuizzes + 1;
      final newAverage = ((currentAverage * totalQuizzes) + score) / newTotal;

      await DatabaseService.highScores.updateOne(
        where.eq('userId', userId).eq('difficulty', difficulty),
        modify
            .set('highestScore', newHighest)
            .set('totalQuizzes', newTotal)
            .set('averageScore', newAverage)
            .set('lastUpdated', DateTime.now()),
      );
    }
  }

  Future<Response> _getHistory(Request request) async {
    try {
      final userId = request.context['userId'] as String;
      final limit = int.tryParse(request.url.queryParameters['limit'] ?? '10') ?? 10;
      final historyList = await DatabaseService.quizHistory
          .find(where.eq('userId', ObjectId.fromHexString(userId)).sortBy('completedAt', descending: true).limit(limit))
          .toList();
      final history = historyList.map((h) => QuizHistory.fromMap(h).toJson()).toList();
      return Response.ok(
        json.encode({'history': history}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in get history: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  Future<Response> _getStats(Request request) async {
    try {
      final userId = request.context['userId'] as String;

      final scoresList = await DatabaseService.highScores
          .find(where.eq('userId', ObjectId.fromHexString(userId)))
          .toList();

      final stats = scoresList.map((s) => HighScore.fromMap(s).toJson()).toList();

      return Response.ok(
        json.encode({'stats': stats}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      print('Error in get stats: $e');
      return Response.internalServerError(
        body: json.encode({'error': 'Internal server error'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}