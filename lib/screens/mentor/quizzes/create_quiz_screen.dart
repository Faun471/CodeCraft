import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final BoardDateTimeTextController dateTimeController =
      BoardDateTimeTextController();
  int _currentStep = 0;

  String _quizTitle = '';
  String _duration = '';
  int _timer = 0;
  final List<Question> _questions = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 3) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              _submitQuiz();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep -= 1;
              });
            }
          },
          steps: [
            Step(
              title: const Text('Quiz Details'),
              content: _buildQuizDetailsStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Timer'),
              content: _buildTimerStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Questions'),
              content: _buildQuestionsStep(),
              isActive: _currentStep >= 2,
            ),
            Step(
              title: const Text('Duration'),
              content: _buildDurationStep(),
              isActive: _currentStep >= 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizDetailsStep() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Quiz Title'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a quiz title';
        }
        return null;
      },
      onSaved: (value) {
        _quizTitle = value!;
      },
    );
  }

  Widget _buildTimerStep() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Timer (in seconds)'),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a timer value';
        }
        if (int.tryParse(value) == null) {
          return 'Please enter a valid number';
        }
        return null;
      },
      onSaved: (value) {
        _timer = int.parse(value!);
      },
    );
  }

  Widget _buildQuestionsStep() {
    return Column(
      children: [
        ..._questions.asMap().entries.map((entry) {
          int idx = entry.key;
          Question question = entry.value;
          return ListTile(
            title: Text('Question ${idx + 1}'),
            subtitle: Text(question.questionText),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editQuestion(idx),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _questions.removeAt(idx);
                    });
                  },
                ),
              ],
            ),
          );
        }),
        ElevatedButton(
          onPressed: _addQuestion,
          child: const Text('Add Question'),
        ),
      ],
    );
  }

  Widget _buildDurationStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BoardDateTimeInputField(
          controller: dateTimeController,
          pickerType: DateTimePickerType.datetime,
          initialDate: _duration.toDateTime(),
          minimumDate: DateTime.now(),
          maximumDate: DateTime.now().add(const Duration(days: 365)),
          options: const BoardDateTimeOptions(
            languages: BoardPickerLanguages.en(),
          ),
          textStyle: Theme.of(context).textTheme.bodyMedium,
          onChanged: (date) {
            _duration = date.toIso8601String();
          },
        ),
      ),
    );
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String questionText = '';
        List<String> options = [];
        String correctAnswer = '';

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Question'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    this.setState(() {
                      _questions.add(Question(
                        questionText: questionText,
                        answerOptions: options,
                        correctAnswer: correctAnswer,
                      ));
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Question Text'),
                        onChanged: (value) {
                          questionText = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(4, (index) {
                        return Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}'),
                              onChanged: (value) {
                                setState(() {
                                  if (options.length <= index) {
                                    options.add(value);
                                  } else {
                                    options[index] = value;
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                          ],
                        );
                      }),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Correct Answer'),
                        items: options.asMap().entries.map((entry) {
                          int idx = entry.key;
                          String option = entry.value;
                          return DropdownMenuItem(
                            value: option,
                            child: Text('Option ${idx + 1}'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          correctAnswer = value!;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _editQuestion(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            String questionText = _questions[index].questionText;
            List<String> options = List.from(_questions[index].answerOptions);
            String correctAnswer = _questions[index].correctAnswer;

            return AlertDialog(
              title: const Text('Edit Question'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (questionText.isNotEmpty && correctAnswer.isNotEmpty) {
                      setState(() {
                        _questions[index] = Question(
                          questionText: questionText,
                          answerOptions: options
                              .where((option) => option.isNotEmpty)
                              .toList(),
                          correctAnswer: correctAnswer,
                        );
                      });
                      Navigator.of(context).pop();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all fields')),
                      );
                    }
                  },
                ),
              ],
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      initialValue: questionText,
                      decoration:
                          const InputDecoration(labelText: 'Question Text'),
                      onChanged: (value) {
                        questionText = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    ...List.generate(4, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          initialValue:
                              index < options.length ? options[index] : '',
                          decoration:
                              InputDecoration(labelText: 'Option ${index + 1}'),
                          onChanged: (value) {
                            setState(() {
                              if (index < options.length) {
                                options[index] = value;
                              } else {
                                options.add(value);
                              }
                            });
                          },
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Correct Answer'),
                      value: correctAnswer,
                      items: [
                        ...options
                            .where((option) => option.isNotEmpty)
                            .map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          correctAnswer = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _submitQuiz() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Quiz quiz = Quiz(
        id: _quizTitle.toSnakeCase(),
        title: _quizTitle,
        questions: _questions,
        timer: _timer,
        duration: _duration,
      );

      QuizService().createQuiz(
        quiz,
        ref.read(appUserNotifierProvider).value!.orgId!,
      );

      ref.read(screenProvider.notifier).popScreen();
    }
  }
}
