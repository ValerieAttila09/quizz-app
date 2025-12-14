# Quiz App Blueprint

## Overview

This document outlines the structure and features of the Quiz App. The app allows users to select a difficulty level, answer a series of questions, and view their score at the end.

## Features

*   **Difficulty Selection:** Users can choose from Easy, Medium, or Hard difficulty levels.
*   **Quiz Interface:** A timed quiz with multiple-choice questions.
*   **Score Screen:** Displays the user's final score.

## Project Structure

```
lib
├── constants.dart
├── controllers
│   └── question_controller.dart
├── models
│   └── Questions.dart
└── screens
    ├── quiz
    │   ├── components
    │   │   ├── body.dart
    │   │   ├── option.dart
    │   │   ├── progress_bar.dart
    │   │   └── question_card.dart
    │   └── quiz_screen.dart
    ├── score
    │   └── score_screen.dart
    └── welcome
        └── welcome_screen.dart
```

## Current Task: Refactor and Clean Up

**Plan:**

1.  **Remove unused files and dependencies:**
    *   Delete `lib/screens/auth/profile_screen.dart`.
    *   Delete `lib/services/quiz_service.dart`.
2.  **Update `lib/screens/score/score_screen.dart`:**
    *   Remove imports for `profile_screen.dart` and `quiz_service.dart`.
    *   Remove the `QuizService` instance and related logic for saving quiz results.
    *   Remove the "View Profile & Stats" button.
3.  **Update `lib/controllers/question_controller.dart`:**
    *   Remove the unnecessary import of `package:get/state_manager.dart`.
4.  **Update `analysis_options.yaml`:**
    *   Ignore the `uri_does_not_exist` error to prevent analysis issues with deleted files.
5.  **Fix deprecation warning:**
    *   In `lib/screens/welcome/welcome_screen.dart`, replace `withOpacity` with `withAlpha`.
