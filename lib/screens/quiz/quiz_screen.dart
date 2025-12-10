import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_app/controllers/question_controller.dart';

import 'components/body.dart';

class QuizScreen extends StatelessWidget {
  final String difficulty;
  
  const QuizScreen({Key? key, this.difficulty = 'Easy'}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    QuestionController _controller = Get.put(QuestionController(difficulty: difficulty));
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        // Fluttter show the back button automatically
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // FlatButton(onPressed: _controller.nextQuestion, child: Text("Skip")),
          FloatingActionButton(onPressed: _controller.nextQuestion, child: Text("Skip"),)
        ],
      ),
      body: Body(),
    );
  }
}