import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  MyApp({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your App Title',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: QuizPage(prefs: prefs),
    );
  }
}

class QuizPage extends StatefulWidget {
  final SharedPreferences prefs;

  QuizPage({required this.prefs});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
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

  List<int> selectedAnswers = List<int>.filled(3, -1);
  bool quizCompleted = false;
  late Timer timer;
  int timeLeft = 120;
  int score = 0; // Declare the score variable

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          timer.cancel();
          handleSubmit();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void handleAnswer(int? questionIndex, int? answerIndex) {
    if (questionIndex != null && answerIndex != null) {
      setState(() {
        selectedAnswers[questionIndex] = answerIndex;
      });
    }
  }

  void handleSubmit() async {
    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] != -1 &&
          questions[i]["answers"][selectedAnswers[i]]["correct"]) {
        score++;
      }
    }

    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/quizScore.json');
    file.writeAsStringSync(jsonEncode({"score": score}));
    await widget.prefs.setBool('quiz_taken', true);

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
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('You have already taken the quiz.'),
                  Text('Your score is: $score'), // Display the score
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Time left: $timeLeft seconds',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20),
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
                  ElevatedButton(
                    onPressed: handleSubmit,
                    child: Text('Submit'),
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
  final void Function(int?) onAnswer;

  QuestionWidget({
    required this.question,
    required this.answers,
    required this.selectedAnswer,
    required this.onAnswer,
  });

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
                onChanged: (int? answerIndex) => onAnswer(answerIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
