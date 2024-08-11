import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

class QuizViewer extends ConsumerStatefulWidget {
  final Quiz quiz;
  final Function(bool, Quiz) onQuizFinished;

  QuizViewer({super.key, required this.quiz, required this.onQuizFinished}) {
    quiz.questions.shuffle();
    for (var question in quiz.questions) {
      question.answerOptions.shuffle();
    }
  }

  @override
  QuizViewerState createState() => QuizViewerState();
}

class QuizViewerState extends ConsumerState<QuizViewer> {
  late Timer _timer;
  late Color _color;
  double _start = 0;
  int currentQuestionIndex = 0;
  int score = 0;
  bool _animating = false;
  bool _shouldAnimateLottie = false;
  bool canAnswer = true;
  String userAnswer = '';

  @override
  void initState() {
    _start = widget.quiz.timer.toDouble();
    startTimer();
    Animate.restartOnHotReload = true;

    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void checkAnswer(String userAnswer) {
    if (widget.quiz
        .checkAnswer(widget.quiz.questions[currentQuestionIndex], userAnswer)) {
      setState(() {
        score++;
        _timer.cancel();
      });
    }

    _animating = true;
  }

  void startTimer() {
    double displayTime = _start;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (_start <= 0.0) {
          timer.cancel();
          setState(() {
            canAnswer = false;
            userAnswer = 'Time\'s Up!';
          });
          return;
        }
        _start -= 1;
        if ((displayTime - _start).abs() >= 0.001) {
          displayTime = _start;
          setState(() {});
        }
      },
    );
  }

  Widget buildAnswerButton(String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AnimatedOpacity(
          opacity: canAnswer ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              onPressed: canAnswer
                  ? () {
                      checkAnswer(answer);
                      setState(() {
                        canAnswer = false;
                        userAnswer = answer;
                        _timer.cancel();
                      });
                    }
                  : null,
              child: AutoSizeText(
                answer,
                minFontSize: 16,
                style: AdaptiveTheme.of(context).theme.textTheme.titleLarge!,
              )).animate(effects: [
            if (!canAnswer)
              ColorEffect(
                begin: Colors.transparent,
                end: Theme.of(context).primaryColor,
                duration: 300.ms,
              ),
          ])),
    ).animate(effects: [
      if (!canAnswer && userAnswer == answer)
        canAnswer
            ? MoveEffect(
                begin: const Offset(-200, 0),
                end: Offset.zero,
                delay: const Duration(milliseconds: 50),
                duration: 600.ms,
                curve: Curves.easeOutQuint)
            : MoveEffect(
                end: const Offset(400, 0),
                begin: Offset.zero,
                delay: const Duration(milliseconds: 300),
                duration: 1000.ms,
                curve: Curves.easeOutQuint),
      FadeEffect(
          duration: 1.seconds,
          begin: canAnswer ? 0.0 : 1.0,
          end: canAnswer ? 1.0 : 0.0)
    ]);
  }

  Widget buildQuestionText() {
    return Animate(
      effects: [
        MoveEffect(
          begin: canAnswer ? const Offset(-200, 0) : Offset.zero,
          end: canAnswer ? Offset.zero : const Offset(0, 150),
          delay: canAnswer
              ? const Duration(milliseconds: 50)
              : const Duration(milliseconds: 750),
          duration: canAnswer ? 300.ms : 600.ms,
          curve: Curves.fastEaseInToSlowEaseOut,
        )
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AutoSizeText(
          widget.quiz.questions[currentQuestionIndex].questionText,
          minFontSize: 24,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  Widget buildFeedbackWidget() {
    return Align(
      alignment: Alignment.center,
      child: AutoSizeText(
        userAnswer,
        minFontSize: 22,
      ).animate(delay: 1.2.seconds, effects: [
        ScaleEffect(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.fastEaseInToSlowEaseOut),
        MoveEffect(
            begin: const Offset(-50, 75),
            end: const Offset(0, 125),
            duration: 600.ms,
            curve: Curves.easeOutQuint),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() {
          if (!canAnswer && !_animating) {
            if (currentQuestionIndex < widget.quiz.questions.length - 1) {
              currentQuestionIndex++;
              canAnswer = true;
              userAnswer = '';
              _start = widget.quiz.timer.toDouble();
              _shouldAnimateLottie = false;
              startTimer();
            } else {
              widget.onQuizFinished(
                  score == widget.quiz.questions.length, widget.quiz);
            }
          }
        }),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (canAnswer)
                  TweenAnimationBuilder(
                    tween: ColorTween(begin: Colors.green, end: Colors.red),
                    duration: widget.quiz.timer.seconds,
                    builder:
                        (BuildContext context, Color? color, Widget? child) {
                      _color = color!;
                      return AnimatedProgressBar(
                        width: MediaQuery.of(context).size.width,
                        value: _start / widget.quiz.timer.toDouble(),
                        duration: 1.seconds,
                        color: color,
                        backgroundColor: Colors.grey.withOpacity(0.8),
                        curve: Curves.linear,
                      );
                    },
                  ),
                if (!canAnswer)
                  ProgressBar(
                    value: (_start / widget.quiz.timer),
                    width: MediaQuery.of(context).size.width,
                    color: _color,
                    backgroundColor: Colors.grey.withOpacity(0.8),
                  ),
                buildQuestionText(),
                ...widget.quiz.questions[currentQuestionIndex].answerOptions
                    .map((answer) => buildAnswerButton(answer)),
                const SizedBox(
                  height: 64,
                ),
              ],
            ),
            if (!canAnswer)
              Align(
                alignment: Alignment.center,
                child: Lottie.asset(
                  userAnswer.isNotEmpty && userAnswer == 'Time\'s Up!'
                      ? 'assets/anim/timeout.json'
                      : widget.quiz.checkAnswer(
                              widget.quiz.questions[currentQuestionIndex],
                              userAnswer)
                          ? 'assets/anim/correct.json'
                          : 'assets/anim/incorrect.json',
                  height: userAnswer == 'Time\'s Up!' ? 200 : 125,
                  width: userAnswer == 'Time\'s Up!' ? 200 : 125,
                  fit: BoxFit.cover,
                  repeat: false,
                  animate: _shouldAnimateLottie,
                ),
              ).animate(
                delay: 750.ms,
                effects: [
                  FadeEffect(
                      begin: 0.0, end: 1.0, duration: 300.ms, delay: 150.ms),
                  ScaleEffect(
                      begin: Offset.zero,
                      end: const Offset(1, 1),
                      duration: 300.ms,
                      delay: 200.ms,
                      curve: Curves.fastEaseInToSlowEaseOut),
                  MoveEffect(
                    begin: const Offset(-200, 0),
                    end: Offset.zero,
                    duration: 750.ms,
                  ),
                ],
              ).callback(
                  duration: 300.ms,
                  callback: (_) {
                    setState(() {
                      _shouldAnimateLottie = true;
                    });
                  }),
            if (!canAnswer) buildFeedbackWidget(),
            if (!canAnswer)
              Align(
                alignment: Alignment.bottomCenter,
                child: const AutoSizeText(
                  'press anywhere to continue...',
                  minFontSize: 8,
                )
                    .animate(
                      delay: 1.5.seconds,
                      effects: [
                        FadeEffect(begin: 0.0, end: 1.0, duration: 1.seconds),
                        MoveEffect(
                            begin: const Offset(0, -15),
                            end: const Offset(0, -20),
                            duration: 500.ms),
                      ],
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .callback(
                      callback: (_) => setState(
                        () {
                          _animating = false;
                        },
                      ),
                    ),
              )
          ],
        ),
      ),
    );
  }
}
