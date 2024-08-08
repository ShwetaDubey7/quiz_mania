import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(Quiz());
}

class Quiz extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Mania',
      home: QuizScreen(),
    );
  }
}

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int selectedAnswerIndex = -1;
  bool isCorrectAnswerSelected = false;
  int currentQuestionIndex = 0;
  final Random random = Random();

  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    final response = await http.get(Uri.parse('https://raw.githubusercontent.com/yourusername/yourrepo/main/questions.json'));

    if (response.statusCode == 200) {
      setState(() {
        questions = List<Map<String, dynamic>>.from(json.decode(response.body));
        currentQuestionIndex = random.nextInt(questions.length);
      });
    } else {
      throw Exception('Failed to load questions');
    }
  }

  void checkAnswer(int index) {
    setState(() {
      selectedAnswerIndex = index;
      isCorrectAnswerSelected = index == questions[currentQuestionIndex]['correctAnswerIndex'];
    });
  }

  void nextQuestion() {
    setState(() {
      selectedAnswerIndex = -1;
      isCorrectAnswerSelected = false;
      currentQuestionIndex = random.nextInt(questions.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz App'),
      ),
      body: questions.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  questions[currentQuestionIndex]['question'],
                  style: const TextStyle(fontSize: 24.0),
                ),
                const SizedBox(height: 20.0),
                ...questions[currentQuestionIndex]['answers'].asMap().entries.map((entry) {
                  int index = entry.key;
                  String answer = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () => checkAnswer(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedAnswerIndex == index
                            ? (isCorrectAnswerSelected ? Colors.green : Colors.red)
                            : null,
                       ),
                       child: Text(answer),
                     ),
                   );
                 }).toList(),
                 SizedBox(height: 20.0),
                 ElevatedButton(
                   onPressed: nextQuestion,
                   child: Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
