import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/controllers/question_controller.dart';
import 'package:quiz_app/screens/auth/profile_screen.dart';
import 'package:quiz_app/screens/welcome/welcome_screen.dart';
import 'package:quiz_app/services/quiz_service.dart';
import 'package:flutter_svg/svg.dart';

class ScoreScreen extends StatefulWidget {
  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  final QuizService _quizService = QuizService();
  bool _isSaving = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _saveQuizResult();
  }

  Future<void> _saveQuizResult() async {
    setState(() => _isSaving = true);

    final QuestionController qnController = Get.find<QuestionController>();

    // Calculate time taken (60 seconds per question minus remaining time)
    final int totalTime = 60 * qnController.questions.length;
    final int remainingTime = qnController.animation.value * 60;
    final int timeTaken = totalTime - remainingTime;

    final result = await _quizService.submitQuiz(
      difficulty: qnController.difficulty,
      score: qnController.numOfCorrectAns,
      totalQuestions: qnController.questions.length,
      timeTaken: timeTaken > 0 ? timeTaken : 1,
    );

    setState(() {
      _isSaving = false;
      _saved = result['success'] ?? false;
    });

    if (!result['success']) {
      Get.snackbar(
        'Warning',
        'Could not save quiz result',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    QuestionController _qnController = Get.find<QuestionController>();
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          SvgPicture.asset("assets/images/bg.svg", fit: BoxFit.fill),
          Column(
            children: [
              Spacer(flex: 3),
              Text(
                "Score",
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(color: kSecondaryColor),
              ),
              Spacer(),
              Text(
                "${_qnController.numOfCorrectAns}/${_qnController.questions.length}",
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(color: kSecondaryColor),
              ),
              SizedBox(height: 10),
              Text(
                _qnController.numOfCorrectAns == _qnController.questions.length
                    ? "Perfect Score! 🎉"
                    : _qnController.numOfCorrectAns >=
                          _qnController.questions.length * 0.7
                    ? "Great Job! 👏"
                    : "Keep Practicing! 💪",
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              SizedBox(height: 20),
              if (_isSaving)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Saving result...",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                )
              else if (_saved)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: kGreenColor, size: 20),
                    SizedBox(width: 8),
                    Text("Result saved!", style: TextStyle(color: kGreenColor)),
                  ],
                ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () => Get.offAll(() => ProfileScreen()),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(kDefaultPadding * 0.75),
                        decoration: BoxDecoration(
                          gradient: kPrimaryGradient,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Text(
                          "View Profile & Stats",
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12),
                    InkWell(
                      onTap: () => Get.offAll(() => WelcomeScreen()),
                      child: Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(kDefaultPadding * 0.75),
                        decoration: BoxDecoration(
                          color: Color(0xFF1C2341),
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Text(
                          "Play Again",
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(flex: 2),
            ],
          ),
        ],
      ),
    );
  }
}
