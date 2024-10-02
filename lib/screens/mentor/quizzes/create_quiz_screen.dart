import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:codecraft/models/app_user_notifier.dart';
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
  final List<Question> _questions = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
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
          onStepTapped: (int index) {
            setState(() {
              _currentStep = index;
            });
          },
          steps: [
            Step(
              title: const Text('Quiz Details'),
              content: _buildQuizDetailsStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Questions'),
              content: _buildQuestionsStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Duration'),
              content: _buildDurationStep(),
              isActive: _currentStep >= 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizDetailsStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Quiz Title',
            hintText: 'Enter a descriptive title for your quiz',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Quiz title is required';
            }
            return null;
          },
          onSaved: (value) {
            _quizTitle = value!;
          },
        ),
      ),
    );
  }

  Widget _buildQuestionsStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Questions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ReorderableListView(
              shrinkWrap: true,
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final question = _questions.removeAt(oldIndex);
                  _questions.insert(newIndex, question);
                });
              },
              children: _questions.asMap().entries.map((entry) {
                int index = entry.key;
                Question question = entry.value;
                return ListTile(
                  key: ValueKey(index),
                  title: Text(question.questionText),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Options: ${question.answerOptions.join(', ')}'),
                      const SizedBox(height: 8),
                      Text('Timer: ${question.initialTimer} seconds'),
                      Slider(
                        value: question.initialTimer!.toDouble(),
                        min: 10,
                        max: 600,
                        divisions: 60,
                        label: '${question.initialTimer} seconds',
                        onChanged: (double value) {
                          setState(() {
                            question.initialTimer = value.toInt();
                          });
                        },
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editQuestion(index);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _questions.removeAt(index);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Add New Question'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 24.0),
                textStyle: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Quiz Duration',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            BoardDateTimeInputField(
              controller: dateTimeController,
              pickerType: DateTimePickerType.date,
              initialDate: _duration.toDateTime(),
              minimumDate: DateTime.now(),
              maximumDate: DateTime.now().add(const Duration(days: 365)),
              options: const BoardDateTimeOptions(
                languages: BoardPickerLanguages.en(),
              ),
              onChanged: (date) {
                setState(() {
                  _duration = date.toIso8601String();
                });
              },
              textStyle: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Select the quiz end date. You can set the quiz to be available for a specific duration.',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    );
  }

  void _addQuestion() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String questionText = '';
        List<String> options = ['', '', '', ''];
        String? correctAnswer;
        int initialTimer = 30;
        int penaltySeconds = 5;
        int maxAttempts = 3; // Default value for max attempts

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Create a map of unique, non-empty options with their indices
            Map<String, int> uniqueOptions = {};
            for (int i = 0; i < options.length; i++) {
              if (options[i].isNotEmpty &&
                  !uniqueOptions.containsKey(options[i])) {
                uniqueOptions[options[i]] = i;
              }
            }

            List<DropdownMenuItem<String>> dropdownItems =
                uniqueOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: entry.value.toString(),
                child: Text(entry.key),
              );
            }).toList();

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
                    if (questionText.isNotEmpty && correctAnswer != null) {
                      setState(() {
                        _questions.add(Question(
                          questionText: questionText,
                          answerOptions: options
                              .where((option) => option.isNotEmpty)
                              .toList(),
                          correctAnswer: options[int.parse(correctAnswer!)],
                          initialTimer: initialTimer,
                          penaltySeconds: penaltySeconds,
                          maxAttempts: maxAttempts, // Set max attempts
                        ));
                      });
                      Navigator.of(context).pop();
                      setState(() {}); // Update the parent widget
                    }
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
                                  options[index] = value;
                                  if (correctAnswer == index.toString() &&
                                      value.isEmpty) {
                                    correctAnswer = null;
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
                        value: correctAnswer,
                        items: dropdownItems,
                        onChanged: (value) {
                          setState(() {
                            correctAnswer = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Initial Timer (seconds)',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: initialTimer.toString(),
                        onChanged: (value) {
                          setState(() {
                            initialTimer = int.tryParse(value) ?? 30;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Penalty (seconds)',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: penaltySeconds.toString(),
                        onChanged: (value) {
                          setState(() {
                            penaltySeconds = int.tryParse(value) ?? 5;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Max Attempts',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: maxAttempts.toString(),
                        onChanged: (value) {
                          setState(() {
                            maxAttempts = int.tryParse(value) ?? 3;
                          });
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
        String questionText = _questions[index].questionText;
        List<String> options = List.from(_questions[index].answerOptions);
        String correctAnswer = _questions[index].correctAnswer;
        int initialTimer = _questions[index].initialTimer!;
        int penaltySeconds = _questions[index].penaltySeconds;
        int maxAttempts = _questions[index].maxAttempts;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                    setState(() {
                      _questions[index] = Question(
                        questionText: questionText,
                        answerOptions: options,
                        correctAnswer: correctAnswer,
                        initialTimer: initialTimer,
                        penaltySeconds: penaltySeconds,
                        maxAttempts: maxAttempts, // Set max attempts
                      );
                    });
                    Navigator.of(context).pop();
                    setState(() {}); // Update the parent widget
                  },
                ),
              ],
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Column(
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
                      ...List.generate(options.length, (index) {
                        return Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                  labelText: 'Option ${index + 1}'),
                              initialValue: options[index],
                              onChanged: (value) {
                                setState(() {
                                  // Ensure unique options
                                  if (!options.contains(value)) {
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
                        value: correctAnswer.isNotEmpty &&
                                options.contains(correctAnswer)
                            ? correctAnswer
                            : null,
                        items: options
                            .where((option) => option.isNotEmpty)
                            .map((option) {
                          return DropdownMenuItem(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            correctAnswer = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Initial Timer (seconds)',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: initialTimer.toString(),
                        onChanged: (value) {
                          setState(() {
                            initialTimer = int.tryParse(value) ?? 30;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Penalty (seconds)',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: penaltySeconds.toString(),
                        onChanged: (value) {
                          setState(() {
                            penaltySeconds = int.tryParse(value) ?? 5;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Max Attempts',
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: maxAttempts.toString(),
                        onChanged: (value) {
                          setState(() {
                            maxAttempts = int.tryParse(value) ?? 3;
                          });
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

  void _submitQuiz() {
    Utils.displayDialog(
      context: context,
      title: 'Are you sure?',
      content: 'Once submitted, these changes cannot be undone.',
      lottieAsset: 'assets/anim/question.json',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              Quiz quiz = Quiz(
                id: _quizTitle.toSnakeCase(),
                title: _quizTitle,
                questions: _questions,
                duration: _duration,
                experienceToEarn: 0,
              );

              try {
                await QuizService().createQuiz(
                  quiz,
                  ref.read(appUserNotifierProvider).value!.orgId!,
                );

                if (!mounted) return;

                Utils.displayDialog(
                  context: context,
                  title: 'Success',
                  content: 'Quiz submitted successfully.',
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              } catch (e) {
                if (!mounted) return;

                Utils.displayDialog(
                  context: context,
                  title: 'Error',
                  content: 'An error occurred while submitting the quiz.',
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
              }

              ref.read(screenProvider.notifier).popScreen();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
