import 'package:quiz_app/models/api/user_model.dart';

class AuthService {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<User> loginWithUsername(String username) async {
    // Simply create a user with the provided username
    _currentUser = User(username: username);
    return _currentUser!;
  }

  void logout() {
    _currentUser = null;
  }
}