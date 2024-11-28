import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  final Quiz? quiz;

  const CreateQuizScreen({super.key, this.quiz});

  @override
  _CreateQuizScreenState createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  String _quizTitle = '';
  String _duration = '';
  final List<Question> _questions = [];

  final fields = <int, Key>{
    0: Key('quizDetails'),
    1: Key('questions'),
    2: Key('duration'),
  };

  @override
  void initState() {
    super.initState();
    if (widget.quiz != null) {
      _quizTitle = widget.quiz!.title;
      _duration = widget.quiz!.duration;
      _questions.addAll(widget.quiz!.questions);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
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
                if (_formKey.currentState!.validate()) {
                  _submitQuiz();
                } else {
                  Utils.displayDialog(
                    context: context,
                    title: 'Please complete all steps',
                    content: 'Ensure all fields are filled correctly.',
                    lottieAsset: 'assets/anim/error.json',
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Ok'),
                      ),
                    ],
                    onDismiss: () {
                      final firstInvalidStep = _formKey.currentState!
                          .validateGranularly()
                          .first
                          .widget
                          .key!;

                      setState(() {
                        _currentStep = fields.entries
                            .firstWhere(
                                (entry) => entry.value == firstInvalidStep)
                            .key;
                      });
                    },
                  );
                }
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() {
                  _currentStep -= 1;
                });
              }

              if (_currentStep == 0) {
                _cancelChallenge();
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
      ),
    );
  }

  Widget _buildQuizDetailsStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextFormField(
          key: fields[0],
          initialValue: _quizTitle,
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
          key: fields[1],
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Questions',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ReorderableListView(
              shrinkWrap: true,
              buildDefaultDragHandles: false,
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
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_handle,
                          color: Colors.grey,
                        ),
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
        padding: const EdgeInsets.all(8.0),
        child: OmniDateTimePicker(
          key: fields[4],
          initialDate: _duration.toDateTime(),
          onDateTimeChanged: (date) {
            setState(() {
              _duration = date.toIso8601String();
            });
          },
        ),
      ),
    );
  }

  void _showQuestionDialog({Question? question, int? index}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String questionText = question?.questionText ?? '';
        List<String> options = question?.answerOptions ?? ['', '', '', ''];
        String? correctAnswer = question != null
            ? options.indexOf(question.correctAnswer).toString()
            : null;
        String initialTimer = question?.initialTimer.toString() ?? '30';
        String penaltySeconds = question?.penaltySeconds.toString() ?? '5';
        String maxAttempts = question?.maxAttempts.toString() ?? '3';
        final formKey = GlobalKey<FormState>();

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            // Create a map of unique, non-empty options with their indices
            Map<String, int> uniqueOptions = {};
            for (int i = 0; i < options.length; i++) {
              if (options[i].isNotEmpty) {
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
              title: Text(question == null ? 'Add Question' : 'Edit Question'),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(question == null ? 'Add' : 'Save'),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      final newQuestion = Question(
                        questionText: questionText,
                        answerOptions: options
                            .where((option) => option.isNotEmpty)
                            .toList(),
                        correctAnswer: options[int.parse(correctAnswer!)],
                        initialTimer: int.parse(initialTimer),
                        penaltySeconds: int.parse(penaltySeconds),
                        maxAttempts: int.parse(maxAttempts),
                      );

                      setState(() {
                        if (question == null) {
                          _questions.add(newQuestion);
                        } else {
                          _questions[index!] = newQuestion;
                        }
                      });

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: questionText,
                          decoration: const InputDecoration(
                            labelText: 'Question Text',
                            helperText: 'Required',
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().isEmpty) {
                              return 'Question text is required';
                            }
                            return null;
                          },
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
                                  labelText: 'Option ${index + 1}',
                                  helperText: 'Required',
                                ),
                                initialValue: options[index],
                                validator: (value) {
                                  if (value == null) {
                                    return 'Option ${index + 1} is required';
                                  }

                                  value = value.trim();

                                  if (value.isEmpty) {
                                    return 'Option ${index + 1} is required';
                                  }

                                  // Check for duplicate options
                                  if (options.where((o) => o == value).length >
                                      1) {
                                    return 'Duplicate options are not allowed';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    options[index] = value.trim();
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
                          decoration: const InputDecoration(
                            labelText: 'Correct Answer',
                            helperText: 'Required',
                          ),
                          value: correctAnswer,
                          items: dropdownItems,
                          validator: (value) {
                            if (value == null) {
                              return 'Please select the correct answer';
                            }
                            return null;
                          },
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
                            helperText: 'Enter a number between 10 and 600',
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: initialTimer,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Initial timer is required';
                            }
                            final number = int.tryParse(value);
                            if (number == null) {
                              return 'Please enter a valid number';
                            }
                            if (number < 10 || number > 600) {
                              return 'Timer must be between 10 and 600 seconds';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            initialTimer = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Penalty (seconds)',
                            helperText: 'Enter a number between 0 and 60',
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: penaltySeconds,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Penalty seconds is required';
                            }
                            final number = int.tryParse(value);
                            if (number == null) {
                              return 'Please enter a valid number';
                            }
                            if (number < 0 || number > 60) {
                              return 'Penalty must be between 0 and 60 seconds';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            penaltySeconds = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Max Attempts',
                            helperText: 'Enter a number between 1 and 10',
                          ),
                          keyboardType: TextInputType.number,
                          initialValue: maxAttempts,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Max attempts is required';
                            }
                            final number = int.tryParse(value);
                            if (number == null) {
                              return 'Please enter a valid number';
                            }
                            if (number < 1 || number > 10) {
                              return 'Max attempts must be between 1 and 10';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            maxAttempts = value;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _addQuestion() {
    _showQuestionDialog();
  }

  void _editQuestion(int index) {
    _showQuestionDialog(question: _questions[index], index: index);
  }

  void _cancelChallenge() {
    Utils.displayDialog(
      context: context,
      title: 'Are you sure you want to cancel?',
      content: 'All changes will be lost.',
      lottieAsset: 'assets/anim/question.json',
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('No, Continue Editing'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            ref.read(screenProvider.notifier).popScreen();
          },
          child: const Text('Yes, Cancel'),
        ),
      ],
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

              if (quiz.questions.isEmpty) {
                Utils.displayDialog(
                  context: context,
                  title: 'No Questions Added',
                  content: 'Please add at least one question to the quiz.',
                  lottieAsset: 'assets/anim/error.json',
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('OK'),
                    ),
                  ],
                );
                return;
              }

              try {
                await QuizService().createQuiz(
                  quiz,
                  ref.read(appUserNotifierProvider).value!.orgId!,
                );

                if (!mounted) return;

                Navigator.of(context).pop();

                Utils.displayDialog(
                  context: context,
                  title: 'Success',
                  content: 'Quiz submitted successfully.',
                  lottieAsset: 'assets/anim/congrats.json',
                );
              } on FirebaseException catch (e) {
                if (!mounted) return;

                if (e.code == 'permission-denied') {
                  Utils.displayDialog(
                    context: context,
                    title: 'Permission Denied',
                    content:
                        'You do not have permission to create a debugging challenge.\nPlease check if your plan is still active.',
                    lottieAsset: 'assets/anim/error.json',
                  );
                  return;
                }
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
