import 'package:codecraft/models/quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

class CompletedQuizScreen extends ConsumerStatefulWidget {
  final Quiz quiz;

  const CompletedQuizScreen({super.key, required this.quiz});

  @override
  _CompletedQuizScreenState createState() => _CompletedQuizScreenState();
}

class _CompletedQuizScreenState extends ConsumerState<CompletedQuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Completed Quiz"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SmoothListView.builder(
              duration: const Duration(milliseconds: 300),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.quiz.questions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.quiz.questions[index].questionText),
                  subtitle: const Text("Your answer: "),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
