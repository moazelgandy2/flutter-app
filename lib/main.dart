import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: QuizPage(),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Quiz data
  List<Map<String, dynamic>> questions = [
    {
      "question": "What is the tallest bridge?",
      "answers": [
        {"answer": "Millau Viaduct", "correct": true},
        {"answer": "Akashi Kaikyō Bridge", "correct": false},
        {"answer": "Yangsigang Yangtze River Bridge", "correct": false},
        {"answer": "Yavuz Sultan Selim Bridge", "correct": false},
      ],
    },
    {
      "question": "What is the longest river?",
      "answers": [
        {"answer": "Nile", "correct": false},
        {"answer": "Amazon", "correct": true},
        {"answer": "Yangtze", "correct": false},
        {"answer": "Mississippi-Missouri", "correct": false},
      ],
    },
    {
      "question": "What is the largest ocean?",
      "answers": [
        {"answer": "Atlantic", "correct": false},
        {"answer": "Indian", "correct": false},
        {"answer": "Southern", "correct": false},
        {"answer": "Pacific", "correct": true},
      ],
    },
  ];

  // State variables
  List<int> selectedAnswers = List<int>.filled(3, -1);
  bool quizCompleted = false;

  @override
  void initState() {
    super.initState();
    checkQuizTaken();
  }

  // Check if the quiz has been taken before
  void checkQuizTaken() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/quizScore.json');
    if (file.existsSync()) {
      setState(() {
        quizCompleted = true;
      });
    }
  }

  // Move to the next question
  void handleNext() {
    setState(() {
      if (selectedAnswers.length - 1 > questions.length) return;
      selectedAnswers.add(-1);
    });
  }

  // Move to the previous question
  void handlePrev() {
    setState(() {
      if (selectedAnswers.length == 0) return;
      selectedAnswers.removeLast();
    });
  }

  // Handle answer selection
  void handleAnswer(int? questionIndex, int? answerIndex) {
    if (questionIndex != null && answerIndex != null) {
      setState(() {
        selectedAnswers[questionIndex] = answerIndex;
      });
    }
  }

  // Handle quiz submission
  void handleSubmit() async {
    int score = 0;
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] != -1 &&
          questions[i]["answers"][selectedAnswers[i]]["correct"]) {
        score++;
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/quizScore.json');
    file.writeAsStringSync(jsonEncode({"score": score}));

    setState(() {
      quizCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz App'),
      ),
      body: Center(
        child: quizCompleted
            ? Text('You have already taken the quiz.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: questions.length,
                      itemBuilder: (BuildContext context, int index) {
                        return QuestionWidget(
                          question: questions[index]["question"],
                          answers: questions[index]["answers"],
                          selectedAnswer: selectedAnswers[index],
                          onAnswer: (int? answerIndex) =>
                              handleAnswer(index, answerIndex),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: handlePrev,
                        child: Text('Prev'),
                      ),
                      ElevatedButton(
                        onPressed: handleNext,
                        child: Text('Next'),
                      ),
                      ElevatedButton(
                        onPressed: handleSubmit,
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final String question;
  final List<Map<String, dynamic>> answers;
  final int selectedAnswer;
  final void Function(int?)
      onAnswer; // Update parameter type to accept nullable int

  QuestionWidget(
      {required this.question,
      required this.answers,
      required this.selectedAnswer,
      required this.onAnswer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 8.0),
          Column(
            children: List.generate(
              answers.length,
              (index) => RadioListTile(
                title: Text(answers[index]["answer"]),
                value: index,
                groupValue: selectedAnswer,
                onChanged: (int? answerIndex) =>
                    onAnswer(answerIndex), // Update parameter type
              ),
            ),
          ),
        ],
      ),
    );
  }
}
