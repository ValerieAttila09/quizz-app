import 'package:get/get.dart';
import '../models/api/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  final Rx<UserModel?> _user = Rx<UserModel?>(null);
  UserModel? get user => _user.value;
  
  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  
  final RxBool _isLoggedIn = false.obs;
  bool get isLoggedIn => _isLoggedIn.value;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    _isLoading.value = true;
    final loggedIn = await _authService.isLoggedIn();
    _isLoggedIn.value = loggedIn;
    
    if (loggedIn) {
      final userData = await _authService.getUser();
      _user.value = userData;
    }
    
    _isLoading.value = false;
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String fullName,
  }) async {
    _isLoading.value = true;
    try {
      final result = await _authService.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
      );
      
      if (result['success']) {
        _user.value = result['user'];
        _isLoggedIn.value = true;
      }
      
      return result;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    _isLoading.value = true;
    
    final result = await _authService.login(
      email: email,
      password: password,
    );
    
    if (result['success']) {
      _user.value = result['user'];
      _isLoggedIn.value = true;
    }
    
    _isLoading.value = false;
    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user.value = null;
    _isLoggedIn.value = false;
  }

  Future<void> refreshProfile() async {
    final result = await _authService.getProfile();
    if (result['success']) {
      _user.value = result['user'];
    }
  }
}