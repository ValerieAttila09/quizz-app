import 'package:mongo_dart/mongo_dart.dart';

class DatabaseService {
  static Db? _db;
  static DbCollection? _usersCollection;
  static DbCollection? _quizHistoryCollection;
  static DbCollection? _highScoresCollection;

  static Future<void> connect(String mongoUri) async {
    try {
      _db = await Db.create(mongoUri);
      // The `secure: true` parameter is the correct way to enable TLS/SSL.
      await _db!.open(secure: true);
      
      print('✅ Connected to MongoDB successfully!');
      
      // Initialize collections
      _usersCollection = _db!.collection('users');
      _quizHistoryCollection = _db!.collection('quiz_history');
      _highScoresCollection = _db!.collection('high_scores');
      
      // Create indexes
      await _createIndexes();
    } catch (e) {
      print('❌ Error connecting to MongoDB: $e');
      rethrow;
    }
  }

  static Future<void> _createIndexes() async {
    try {
      // Unique index for email
      await _usersCollection!.createIndex(
        key: 'email',
        unique: true,
      );
      
      // Unique index for username
      await _usersCollection!.createIndex(
        key: 'username',
        unique: true,
      );
      
      // Index for quiz history by userId
      await _quizHistoryCollection!.createIndex(
        key: 'userId',
      );
      
      // Index for high scores by userId and difficulty
      await _highScoresCollection!.createIndex(
        keys: {
          'userId': 1,
          'difficulty': 1,
        },
        unique: true,
      );
      
      print('✅ Database indexes created successfully!');
    } catch (e) {
      print('⚠️  Warning: Error creating indexes: $e');
    }
  }

  static DbCollection get users {
    if (_usersCollection == null) {
      throw Exception('Database not connected. Call connect() first.');
    }
    return _usersCollection!;
  }

  static DbCollection get quizHistory {
    if (_quizHistoryCollection == null) {
      throw Exception('Database not connected. Call connect() first.');
    }
    return _quizHistoryCollection!;
  }

  static DbCollection get highScores {
    if (_highScoresCollection == null) {
      throw Exception('Database not connected. Call connect() first.');
    }
    return _highScoresCollection!;
  }

  static Future<void> close() async {
    await _db?.close();
    print('✅ Database connection closed.');
  }
}