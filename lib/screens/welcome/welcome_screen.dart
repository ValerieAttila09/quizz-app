import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:quiz_app/constants.dart';
import 'package:quiz_app/controllers/auth_controller.dart';
import 'package:quiz_app/screens/auth/profile_screen.dart';
import 'package:quiz_app/screens/quiz/quiz_screen.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String selectedDifficulty = 'Easy';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SvgPicture.asset("assets/images/bg.svg", fit: BoxFit.fill),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.person, color: Colors.white, size: 28),
                        onPressed: () => Get.to(() => ProfileScreen()),
                      ),
                    ],
                  ),
                  Spacer(flex: 2), //2/6
                  Text(
                    "Let's Play Quiz,",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text("Choose your difficulty level"),
                  SizedBox(height: kDefaultPadding),
                  _buildLevelButton(
                    context,
                    'Easy',
                    '🟢 EASY',
                    Color(0xFF6AC259),
                  ),
                  SizedBox(height: 12),
                  _buildLevelButton(
                    context,
                    'Medium',
                    '🟡 MEDIUM',
                    Color(0xFFFFA500),
                  ),
                  SizedBox(height: 12),
                  _buildLevelButton(
                    context,
                    'Hard',
                    '🔴 HARD',
                    Color(0xFFE92E30),
                  ),
                  Spacer(), // 1/6
                  Text("Enter your name", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color(0xFF1C2341),
                      hintText: "Full Name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(height: kDefaultPadding),
                  InkWell(
                    onTap: () => Get.to(() => QuizScreen(difficulty: selectedDifficulty)),
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(kDefaultPadding * 0.75), // 15
                      decoration: BoxDecoration(
                        gradient: kPrimaryGradient,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Text(
                        "Lets Start Quiz",
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  Spacer(flex: 2), // it will take 2/6 spaces
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelButton(BuildContext context, String difficulty, String label, Color color) {
    bool isSelected = selectedDifficulty == difficulty;
    
    return InkWell(
      onTap: () {
        setState(() {
          selectedDifficulty = difficulty;
        });
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(kDefaultPadding * 0.75),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.3) : Color(0xFF1C2341),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? color : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) ...[
              SizedBox(width: 8),
              Icon(Icons.check_circle, color: color, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}