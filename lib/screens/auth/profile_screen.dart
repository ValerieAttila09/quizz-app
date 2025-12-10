import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/controllers/auth_controller.dart';
import 'package:quiz_app/models/api/high_score_model.dart';
import 'package:quiz_app/models/api/quiz_history_model.dart';
import 'package:quiz_app/screens/auth/login_screen.dart';
import 'package:quiz_app/screens/welcome/welcome_screen.dart';
import 'package:quiz_app/services/quiz_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final QuizService _quizService = QuizService();
  List<HighScoreModel> _stats = [];
  List<QuizHistoryModel> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final statsResult = await _quizService.getStats();
    final historyResult = await _quizService.getHistory(limit: 5);
    
    if (statsResult['success']) {
      _stats = statsResult['stats'];
    }
    
    if (historyResult['success']) {
      _history = historyResult['history'];
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _handleLogout() async {
    final authController = Get.find<AuthController>();
    await authController.logout();
    Get.offAll(() => LoginScreen());
    Get.snackbar(
      'Success',
      'Logged out successfully',
      backgroundColor: kGreenColor,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.user;

    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset("assets/images/bg.svg", fit: BoxFit.fill),
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(kDefaultPadding),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Expanded(
                        child: Text(
                          "Profile",
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.logout, color: kRedColor),
                        onPressed: _handleLogout,
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Info Card
                              Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(kDefaultPadding),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1C2341),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: kPrimaryGradient.colors[0],
                                      child: Text(
                                        (user?.fullName.isNotEmpty == true) 
                                            ? user!.fullName[0].toUpperCase() 
                                            : 'U',
                                        style: TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      user?.fullName ?? 'User',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      '@${user?.username ?? 'username'}',
                                      style: TextStyle(color: kSecondaryColor),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      user?.email ?? 'email@example.com',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24),
                              
                              // Statistics Section
                              Text(
                                "📊 Your Statistics",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 12),
                              
                              if (_stats.isEmpty)
                                Container(
                                  padding: EdgeInsets.all(kDefaultPadding),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1C2341),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "No quiz attempts yet. Start playing to see your stats!",
                                    style: TextStyle(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              else
                                ..._stats.map((stat) => Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      padding: EdgeInsets.all(kDefaultPadding),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1C2341),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            stat.emoji,
                                            style: TextStyle(fontSize: 24),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  stat.difficulty,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Text(
                                                  'Avg: ${stat.averageScore.toStringAsFixed(1)} | Played: ${stat.totalQuizzes}',
                                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '${stat.highestScore}',
                                            style: TextStyle(
                                              color: kGreenColor,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            ' 🏆',
                                            style: TextStyle(fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    )),
                              
                              SizedBox(height: 24),
                              
                              // Recent History Section
                              Text(
                                "📜 Recent History",
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              SizedBox(height: 12),
                              
                              if (_history.isEmpty)
                                Container(
                                  padding: EdgeInsets.all(kDefaultPadding),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF1C2341),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "No quiz history yet. Start playing!",
                                    style: TextStyle(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              else
                                ..._history.map((quiz) => Container(
                                      margin: EdgeInsets.only(bottom: 12),
                                      padding: EdgeInsets.all(kDefaultPadding),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF1C2341),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${quiz.difficulty} Quiz',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  quiz.formattedDate,
                                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '${quiz.score}/${quiz.totalQuestions}',
                                                style: TextStyle(
                                                  color: quiz.score == quiz.totalQuestions
                                                      ? kGreenColor
                                                      : Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              Text(
                                                quiz.formattedTime,
                                                style: TextStyle(color: Colors.white70, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )),
                              
                              SizedBox(height: 20),
                              
                              // Start New Quiz Button
                              InkWell(
                                onTap: () => Get.offAll(() => WelcomeScreen()),
                                child: Container(
                                  width: double.infinity,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.all(kDefaultPadding * 0.75),
                                  decoration: BoxDecoration(
                                    gradient: kPrimaryGradient,
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  child: Text(
                                    "Start New Quiz",
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(color: Colors.black, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(height: 40),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}