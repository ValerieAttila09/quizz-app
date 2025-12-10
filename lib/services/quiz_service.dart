import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api/quiz_history_model.dart';
import '../models/api/high_score_model.dart';
import 'auth_service.dart';

class QuizService {
  static const String baseUrl = 'http://localhost:9925/api';
  final AuthService _authService = AuthService();

  // Submit quiz result
  Future<Map<String, dynamic>> submitQuiz({
    required String difficulty,
    required int score,
    required int totalQuestions,
    required int timeTaken,
  }) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/quiz/submit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'difficulty': difficulty,
          'score': score,
          'totalQuestions': totalQuestions,
          'timeTaken': timeTaken,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to submit quiz'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get quiz history
  Future<Map<String, dynamic>> getHistory({int limit = 10}) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/quiz/history?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final historyList = (data['history'] as List)
            .map((item) => QuizHistoryModel.fromJson(item))
            .toList();
        return {'success': true, 'history': historyList};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get history'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  // Get user stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/quiz/stats'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final statsList = (data['stats'] as List)
            .map((item) => HighScoreModel.fromJson(item))
            .toList();
        return {'success': true, 'stats': statsList};
      } else {
        return {'success': false, 'error': data['error'] ?? 'Failed to get stats'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}