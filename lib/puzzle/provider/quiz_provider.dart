import 'package:flutter/material.dart';
import 'dart:math';
import '../models/question.dart';
import '../models/level.dart';

class QuizProvider extends ChangeNotifier {
  int _currentScore = 0;
  int _currentLevel = 1;
  List<Level> _levels = [];
  List<Question> _currentQuestions = [];

  // Add a currentUser property
  final Map<String, dynamic> _currentUser = {
    'name': 'Default User', // Example user data
  };

  QuizProvider() {
    _initializeLevels();
  }

  int get currentScore => _currentScore;
  int get currentLevel => _currentLevel;
  List<Level> get levels => _levels;
  List<Question> get currentQuestions => _currentQuestions;
  Map<String, dynamic> get currentUser =>
      _currentUser; // Getter for currentUser

  // Initialize levels with an initial sublevel of 1 (easy)
  void _initializeLevels() {
    _levels = [
      Level(
          id: 1,
          name: "Addition",
          icon: "assets/icons/addition.png",
          isUnlocked: true,
          position: Point(0.1, 0.7),
          sublevel: 1,
          totalSublevels: 3),
      Level(
          id: 2,
          name: "Subtraction",
          icon: "assets/icons/subtraction.png",
          isUnlocked: false,
          position: Point(0.8, 0.6),
          sublevel: 1,
          totalSublevels: 3),
      Level(
          id: 3,
          name: "Multiplication",
          icon: "assets/icons/multiplication.png",
          isUnlocked: false,
          position: Point(0.1, 0.5),
          sublevel: 1,
          totalSublevels: 3),
      Level(
          id: 4,
          name: "Division",
          icon: "assets/icons/division.png",
          isUnlocked: false,
          position: Point(0.8, 0.4),
          sublevel: 1,
          totalSublevels: 3),
      Level(
          id: 5,
          name: "Exponents",
          icon: "assets/icons/exponents.png",
          isUnlocked: false,
          position: Point(0.1, 0.3),
          sublevel: 1,
          totalSublevels: 3),
      Level(
          id: 6,
          name: "Square Roots",
          icon: "assets/icons/squareroot.png",
          isUnlocked: false,
          position: Point(0.8, 0.2),
          sublevel: 1,
          totalSublevels: 3),
    ];
  }

// Load questions for a given level and sublevel (difficulty).
// For example, sublevel 1 = easy, 2 = medium, 3 = hard.
  void loadQuestionsForSublevel(int levelId, int sublevel) {
    Map<int, List<Question>> questionData = {
      1: [
        // Easy
        Question(
            id: 1,
            text: "5 + 3",
            options: ["6", "7", "8", "9"],
            correctAnswer: "8",
            difficulty: 1),
        Question(
            id: 2,
            text: "8 + 7",
            options: ["13", "14", "15", "16"],
            correctAnswer: "15",
            difficulty: 1),
        Question(
            id: 3,
            text: "12 + 9",
            options: ["19", "20", "21", "22"],
            correctAnswer: "21",
            difficulty: 1),
        Question(
            id: 4,
            text: "6 + 11",
            options: ["16", "17", "18", "19"],
            correctAnswer: "17",
            difficulty: 1),
        Question(
            id: 5,
            text: "14 + 8",
            options: ["20", "21", "22", "23"],
            correctAnswer: "22",
            difficulty: 1),
        // Medium
        Question(
            id: 6,
            text: "27 + 15",
            options: ["40", "42", "44", "45"],
            correctAnswer: "42",
            difficulty: 2),
        Question(
            id: 7,
            text: "63 + 29",
            options: ["90", "91", "92", "93"],
            correctAnswer: "92",
            difficulty: 2),
        Question(
            id: 8,
            text: "45 + 38",
            options: ["81", "82", "83", "84"],
            correctAnswer: "83",
            difficulty: 2),
        Question(
            id: 9,
            text: "56 + 47",
            options: ["101", "102", "103", "104"],
            correctAnswer: "103",
            difficulty: 2),
        Question(
            id: 10,
            text: "72 + 59",
            options: ["129", "130", "131", "132"],
            correctAnswer: "131",
            difficulty: 2),
        // Hard
        Question(
            id: 11,
            text: "154 + 289",
            options: ["443", "445", "448", "449"],
            correctAnswer: "443",
            difficulty: 3),
        Question(
            id: 12,
            text: "378 + 456",
            options: ["824", "834", "844", "854"],
            correctAnswer: "834",
            difficulty: 3),
        Question(
            id: 13,
            text: "512 + 389",
            options: ["899", "900", "901", "902"],
            correctAnswer: "901",
            difficulty: 3),
        Question(
            id: 14,
            text: "678 + 495",
            options: ["1163", "1173", "1183", "1193"],
            correctAnswer: "1173",
            difficulty: 3),
        Question(
            id: 15,
            text: "823 + 674",
            options: ["1495", "1496", "1497", "1498"],
            correctAnswer: "1497",
            difficulty: 3),
      ],
      2: [
        // Easy
        Question(
            id: 16,
            text: "9 - 4",
            options: ["3", "4", "5", "6"],
            correctAnswer: "5",
            difficulty: 1),
        Question(
            id: 17,
            text: "15 - 9",
            options: ["4", "5", "6", "7"],
            correctAnswer: "6",
            difficulty: 1),
        Question(
            id: 18,
            text: "18 - 7",
            options: ["9", "10", "11", "12"],
            correctAnswer: "11",
            difficulty: 1),
        Question(
            id: 19,
            text: "22 - 13",
            options: ["7", "8", "9", "10"],
            correctAnswer: "9",
            difficulty: 1),
        Question(
            id: 20,
            text: "25 - 16",
            options: ["7", "8", "9", "10"],
            correctAnswer: "9",
            difficulty: 1),
        // Medium
        Question(
            id: 21,
            text: "48 - 29",
            options: ["17", "18", "19", "20"],
            correctAnswer: "19",
            difficulty: 2),
        Question(
            id: 22,
            text: "72 - 38",
            options: ["32", "33", "34", "35"],
            correctAnswer: "34",
            difficulty: 2),
        Question(
            id: 23,
            text: "85 - 47",
            options: ["36", "37", "38", "39"],
            correctAnswer: "38",
            difficulty: 2),
        Question(
            id: 24,
            text: "93 - 58",
            options: ["33", "34", "35", "36"],
            correctAnswer: "35",
            difficulty: 2),
        Question(
            id: 25,
            text: "107 - 69",
            options: ["36", "37", "38", "39"],
            correctAnswer: "38",
            difficulty: 2),
        // Hard
        Question(
            id: 26,
            text: "217 - 148",
            options: ["68", "69", "70", "71"],
            correctAnswer: "69",
            difficulty: 3),
        Question(
            id: 27,
            text: "456 - 279",
            options: ["175", "176", "177", "178"],
            correctAnswer: "177",
            difficulty: 3),
        Question(
            id: 28,
            text: "512 - 389",
            options: ["121", "122", "123", "124"],
            correctAnswer: "123",
            difficulty: 3),
        Question(
            id: 29,
            text: "678 - 495",
            options: ["181", "182", "183", "184"],
            correctAnswer: "183",
            difficulty: 3),
        Question(
            id: 30,
            text: "823 - 674",
            options: ["147", "148", "149", "150"],
            correctAnswer: "149",
            difficulty: 3),
      ],
      3: [
        // Easy
        Question(
            id: 31,
            text: "6 × 3",
            options: ["16", "17", "18", "19"],
            correctAnswer: "18",
            difficulty: 1),
        Question(
            id: 32,
            text: "7 × 4",
            options: ["26", "27", "28", "29"],
            correctAnswer: "28",
            difficulty: 1),
        Question(
            id: 33,
            text: "8 × 5",
            options: ["35", "36", "40", "45"],
            correctAnswer: "40",
            difficulty: 1),
        Question(
            id: 34,
            text: "9 × 6",
            options: ["52", "54", "56", "58"],
            correctAnswer: "54",
            difficulty: 1),
        Question(
            id: 35,
            text: "12 × 7",
            options: ["82", "84", "86", "88"],
            correctAnswer: "84",
            difficulty: 1),
        // Medium
        Question(
            id: 36,
            text: "14 × 7",
            options: ["96", "97", "98", "99"],
            correctAnswer: "98",
            difficulty: 2),
        Question(
            id: 37,
            text: "18 × 6",
            options: ["106", "107", "108", "109"],
            correctAnswer: "108",
            difficulty: 2),
        Question(
            id: 38,
            text: "23 × 9",
            options: ["205", "206", "207", "208"],
            correctAnswer: "207",
            difficulty: 2),
        Question(
            id: 39,
            text: "25 × 8",
            options: ["198", "200", "202", "204"],
            correctAnswer: "200",
            difficulty: 2),
        Question(
            id: 40,
            text: "32 × 7",
            options: ["222", "224", "226", "228"],
            correctAnswer: "224",
            difficulty: 2),
        // Hard
        Question(
            id: 41,
            text: "23 × 19",
            options: ["435", "436", "437", "438"],
            correctAnswer: "437",
            difficulty: 3),
        Question(
            id: 42,
            text: "34 × 22",
            options: ["746", "748", "750", "752"],
            correctAnswer: "748",
            difficulty: 3),
        Question(
            id: 43,
            text: "45 × 27",
            options: ["1205", "1215", "1225", "1235"],
            correctAnswer: "1215",
            difficulty: 3),
        Question(
            id: 44,
            text: "56 × 34",
            options: ["1894", "1904", "1914", "1924"],
            correctAnswer: "1904",
            difficulty: 3),
        Question(
            id: 45,
            text: "67 × 45",
            options: ["2995", "3005", "3015", "3025"],
            correctAnswer: "3015",
            difficulty: 3),
      ],
      4: [
        // Easy
        Question(
            id: 46,
            text: "12 ÷ 4",
            options: ["2", "3", "4", "5"],
            correctAnswer: "3",
            difficulty: 1),
        Question(
            id: 47,
            text: "20 ÷ 5",
            options: ["3", "4", "5", "6"],
            correctAnswer: "4",
            difficulty: 1),
        Question(
            id: 48,
            text: "28 ÷ 7",
            options: ["3", "4", "5", "6"],
            correctAnswer: "4",
            difficulty: 1),
        Question(
            id: 49,
            text: "36 ÷ 9",
            options: ["3", "4", "5", "6"],
            correctAnswer: "4",
            difficulty: 1),
        Question(
            id: 50,
            text: "45 ÷ 5",
            options: ["8", "9", "10", "11"],
            correctAnswer: "9",
            difficulty: 1),
        // Medium
        Question(
            id: 51,
            text: "56 ÷ 8",
            options: ["6", "7", "8", "9"],
            correctAnswer: "7",
            difficulty: 2),
        Question(
            id: 52,
            text: "81 ÷ 9",
            options: ["8", "9", "10", "11"],
            correctAnswer: "9",
            difficulty: 2),
        Question(
            id: 53,
            text: "96 ÷ 12",
            options: ["7", "8", "9", "10"],
            correctAnswer: "8",
            difficulty: 2),
        Question(
            id: 54,
            text: "108 ÷ 9",
            options: ["11", "12", "13", "14"],
            correctAnswer: "12",
            difficulty: 2),
        Question(
            id: 55,
            text: "144 ÷ 12",
            options: ["10", "11", "12", "13"],
            correctAnswer: "12",
            difficulty: 2),
        // Hard
        Question(
            id: 56,
            text: "225 ÷ 15",
            options: ["14", "15", "16", "17"],
            correctAnswer: "15",
            difficulty: 3),
        Question(
            id: 57,
            text: "392 ÷ 14",
            options: ["26", "27", "28", "29"],
            correctAnswer: "28",
            difficulty: 3),
        Question(
            id: 58,
            text: "512 ÷ 16",
            options: ["30", "31", "32", "33"],
            correctAnswer: "32",
            difficulty: 3),
        Question(
            id: 59,
            text: "648 ÷ 18",
            options: ["34", "35", "36", "37"],
            correctAnswer: "36",
            difficulty: 3),
        Question(
            id: 60,
            text: "729 ÷ 27",
            options: ["25", "26", "27", "28"],
            correctAnswer: "27",
            difficulty: 3),
      ],
      5: [
        // Easy
        Question(
            id: 61,
            text: "2^3",
            options: ["6", "7", "8", "9"],
            correctAnswer: "8",
            difficulty: 1),
        Question(
            id: 62,
            text: "3^2",
            options: ["6", "7", "8", "9"],
            correctAnswer: "9",
            difficulty: 1),
        Question(
            id: 63,
            text: "4^2",
            options: ["14", "15", "16", "17"],
            correctAnswer: "16",
            difficulty: 1),
        Question(
            id: 64,
            text: "5^3",
            options: ["123", "124", "125", "126"],
            correctAnswer: "125",
            difficulty: 1),
        Question(
            id: 65,
            text: "6^2",
            options: ["34", "35", "36", "37"],
            correctAnswer: "36",
            difficulty: 1),
        // Medium
        Question(
            id: 66,
            text: "5^4",
            options: ["624", "625", "626", "627"],
            correctAnswer: "625",
            difficulty: 2),
        Question(
            id: 67,
            text: "4^3",
            options: ["62", "63", "64", "65"],
            correctAnswer: "64",
            difficulty: 2),
        Question(
            id: 68,
            text: "6^3",
            options: ["214", "215", "216", "217"],
            correctAnswer: "216",
            difficulty: 2),
        Question(
            id: 69,
            text: "7^2",
            options: ["47", "48", "49", "50"],
            correctAnswer: "49",
            difficulty: 2),
        Question(
            id: 70,
            text: "8^2",
            options: ["62", "63", "64", "65"],
            correctAnswer: "64",
            difficulty: 2),
        // Hard
        Question(
            id: 71,
            text: "7^3",
            options: ["341", "342", "343", "344"],
            correctAnswer: "343",
            difficulty: 3),
        Question(
            id: 72,
            text: "6^4",
            options: ["1294", "1295", "1296", "1297"],
            correctAnswer: "1296",
            difficulty: 3),
        Question(
            id: 73,
            text: "9^3",
            options: ["725", "726", "727", "728"],
            correctAnswer: "729",
            difficulty: 3),
        Question(
            id: 74,
            text: "10^4",
            options: ["9998", "9999", "10000", "10001"],
            correctAnswer: "10000",
            difficulty: 3),
        Question(
            id: 75,
            text: "12^2",
            options: ["142", "143", "144", "145"],
            correctAnswer: "144",
            difficulty: 3),
      ],
      6: [
        // Easy
        Question(
            id: 76,
            text: "sqrt(16)",
            options: ["2", "3", "4", "5"],
            correctAnswer: "4",
            difficulty: 1),
        Question(
            id: 77,
            text: "sqrt(25)",
            options: ["4", "5", "6", "7"],
            correctAnswer: "5",
            difficulty: 1),
        Question(
            id: 78,
            text: "sqrt(36)",
            options: ["5", "6", "7", "8"],
            correctAnswer: "6",
            difficulty: 1),
        Question(
            id: 79,
            text: "sqrt(49)",
            options: ["6", "7", "8", "9"],
            correctAnswer: "7",
            difficulty: 1),
        Question(
            id: 80,
            text: "sqrt(64)",
            options: ["7", "8", "9", "10"],
            correctAnswer: "8",
            difficulty: 1),
        // Medium
        Question(
            id: 81,
            text: "sqrt(121)",
            options: ["10", "11", "12", "13"],
            correctAnswer: "11",
            difficulty: 2),
        Question(
            id: 82,
            text: "sqrt(144)",
            options: ["11", "12", "13", "14"],
            correctAnswer: "12",
            difficulty: 2),
        Question(
            id: 83,
            text: "sqrt(169)",
            options: ["12", "13", "14", "15"],
            correctAnswer: "13",
            difficulty: 2),
        Question(
            id: 84,
            text: "sqrt(196)",
            options: ["13", "14", "15", "16"],
            correctAnswer: "14",
            difficulty: 2),
        Question(
            id: 85,
            text: "sqrt(225)",
            options: ["14", "15", "16", "17"],
            correctAnswer: "15",
            difficulty: 2),
        // Hard
        Question(
            id: 86,
            text: "sqrt(289)",
            options: ["16", "17", "18", "19"],
            correctAnswer: "17",
            difficulty: 3),
        Question(
            id: 87,
            text: "sqrt(400)",
            options: ["18", "19", "20", "21"],
            correctAnswer: "20",
            difficulty: 3),
        Question(
            id: 88,
            text: "sqrt(529)",
            options: ["22", "23", "24", "25"],
            correctAnswer: "23",
            difficulty: 3),
        Question(
            id: 89,
            text: "sqrt(625)",
            options: ["24", "25", "26", "27"],
            correctAnswer: "25",
            difficulty: 3),
        Question(
            id: 90,
            text: "sqrt(729)",
            options: ["26", "27", "28", "29"],
            correctAnswer: "27",
            difficulty: 3),
      ],
    };

    // Retrieve all questions for the specified level.

    // Unlock the next sublevel (difficulty) for the given level.
    List<Question> levelQuestions = questionData[levelId] ?? [];
    // Filter out only the questions for the given sublevel (difficulty).
    _currentQuestions =
        levelQuestions.where((q) => q.difficulty == sublevel).toList();
    Future.delayed(Duration(milliseconds: 10), () {
      notifyListeners();
    });
  }

  void answerQuestion(String answer, int questionId) {
    final question = _currentQuestions.firstWhere((q) => q.id == questionId);
    if (question.correctAnswer == answer) {
      _currentScore += 10;
      notifyListeners();
    }
  }

  // Unlock the next sublevel (difficulty) for the given level.
  void unlockNextSublevel(int levelId) {
    Level level = _levels.firstWhere((l) => l.id == levelId);
    if (level.sublevel < 3) {
      level.sublevel++;
      notifyListeners();
    } else {
      unlockNextLevel();
      notifyListeners();
    }
  }

  // Unlock the next level
  void unlockNextLevel() {
    final currentIndex = _levels.indexWhere((l) => !l.isUnlocked);
    if (currentIndex != -1) {
      _levels[currentIndex].isUnlocked = true;
      notifyListeners();
    }
  }
}
