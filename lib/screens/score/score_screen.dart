import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/controllers/question_controller.dart';
import 'package:quiz_app/screens/welcome/welcome_screen.dart';
import 'package:flutter_svg/svg.dart';

class ScoreScreen extends StatefulWidget {
  @override
  _ScoreScreenState createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
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
              Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: kDefaultPadding,
                ),
                child: Column(
                  children: [
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
                          "Play Again",
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
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
