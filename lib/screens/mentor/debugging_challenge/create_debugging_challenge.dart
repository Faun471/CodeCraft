import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/models/debugging_challenge.dart';
import 'package:codecraft/services/debugging_challenge_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:re_editor/re_editor.dart';

class CreateDebuggingChallengeScreen extends ConsumerStatefulWidget {
  final DebuggingChallenge? challenge;

  const CreateDebuggingChallengeScreen({super.key, this.challenge});

  @override
  _DebuggingChallengeScreenState createState() =>
      _DebuggingChallengeScreenState();
}

class _DebuggingChallengeScreenState
    extends ConsumerState<CreateDebuggingChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _correctLineController = TextEditingController();
  final TextEditingController _expectedOutputController =
      TextEditingController();
  final TextEditingController _attemptsAllowedController =
      TextEditingController();
  final CodeLineEditingController codeLineController =
      CodeLineEditingController();

  int _currentStep = 0;

  late String _title;
  late String _instructions;
  late String _initialCode;
  late int _correctLine;
  late String _expectedOutput;
  late int _attemptsAllowed;
  late String _duration;

  final fields = <int, Key>{
    0: Key('title'),
    1: Key('instructions'),
    2: Key('initialCode'),
    3: Key('correctLine'),
    4: Key('expectedOutput'),
    5: Key('attemptsAllowed'),
    6: Key('duration'),
  };

  @override
  void initState() {
    super.initState();
    if (widget.challenge != null) {
      // Editing mode
      _title = widget.challenge!.title;
      _instructions = widget.challenge!.instructions;
      _initialCode = widget.challenge!.initialCode;
      codeLineController.text = _initialCode;
      _correctLine = widget.challenge!.correctLine;
      _expectedOutput = widget.challenge!.expectedOutput;
      _attemptsAllowed = widget.challenge!.attemptsLeft;
      _duration = widget.challenge!.duration;
    } else {
      // Creation mode
      _title = '';
      _instructions = '';
      _initialCode = '';
      _correctLine = 1;
      _expectedOutput = '';
      _attemptsAllowed = 3;
      _duration = DateTime.now().add(const Duration(days: 1)).toIso8601String();
    }

    _titleController.text = _title;
    _instructionsController.text = _instructions;
    codeLineController.text = _initialCode;
    _correctLineController.text = _correctLine.toString();
    _expectedOutputController.text = _expectedOutput;
    _attemptsAllowedController.text = _attemptsAllowed.toString();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
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
          onStepContinue: () {
            if (_currentStep < 6) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              if (_formKey.currentState!.validate()) {
                _submitDebuggingChallenge();
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
                      _currentStep = fields.keys.firstWhere(
                        (key) => fields[key] == firstInvalidStep,
                      );
                    });
                  },
                );
              }
            }
          },
          steps: [
            Step(
              title: const Text('Title'),
              content: _buildTitleStep(),
              isActive: _currentStep >= 0,
            ),
            Step(
              title: const Text('Instructions'),
              content: _buildInstructionsStep(),
              isActive: _currentStep >= 1,
            ),
            Step(
              title: const Text('Initial Code'),
              content: _buildInitialCodeStep(),
              isActive: _currentStep >= 2,
            ),
            Step(
              title: const Text('Correct Line'),
              content: _buildCorrectLineStep(),
              isActive: _currentStep >= 3,
            ),
            Step(
              title: const Text('Expected Output'),
              content: _buildExpectedOutputStep(),
              isActive: _currentStep >= 4,
            ),
            Step(
              title: const Text('Attempts Allowed'),
              content: _buildAttemptsAllowedStep(),
              isActive: _currentStep >= 5,
            ),
            Step(
              title: const Text('Deadline'),
              content: _buildDurationStep(),
              isActive: _currentStep >= 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          key: fields[0],
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Title',
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the title';
            }
            return null;
          },
          onSaved: (value) {
            _title = value!;
          },
        ),
      ),
    );
  }

  Widget _buildInstructionsStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          key: fields[1],
          controller: _instructionsController,
          decoration: const InputDecoration(labelText: 'Instructions'),
          maxLines: 5,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the instructions';
            }
            return null;
          },
          onSaved: (value) {
            _instructions = value!;
          },
        ),
      ),
    );
  }

  Widget _buildInitialCodeStep() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 30, 30, 30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CodeEditorWidget(
          key: fields[2],
          controller: codeLineController,
        ),
      ),
    );
  }

  Widget _buildCorrectLineStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          key: fields[3],
          controller: _correctLineController,
          decoration: const InputDecoration(labelText: 'Correct Line Number'),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the correct line number';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          onSaved: (value) {
            _correctLine = int.parse(value!);
          },
        ),
      ),
    );
  }

  Widget _buildExpectedOutputStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          key: fields[4],
          controller: _expectedOutputController,
          decoration: const InputDecoration(labelText: 'Expected Output'),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the expected output';
            }
            return null;
          },
          onSaved: (value) {
            _expectedOutput = value!;
          },
        ),
      ),
    );
  }

  Widget _buildAttemptsAllowedStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          key: fields[5],
          controller: _attemptsAllowedController,
          decoration: const InputDecoration(labelText: 'Attempts Allowed'),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the number of attempts allowed';
            }
            if (int.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          onSaved: (value) {
            _attemptsAllowed = int.parse(value!);
          },
        ),
      ),
    );
  }

  Widget _buildDurationStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: OmniDateTimePicker(
          initialDate: DateTime.parse(_duration),
          onDateTimeChanged: (DateTime dateTime) {
            _duration = dateTime.toIso8601String();
          },
        ),
      ),
    );
  }

  Future<void> _cancelChallenge() async {
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

  void _submitDebuggingChallenge() async {
    Utils.displayDialog(
      context: context,
      title: 'Are you sure?',
      content: widget.challenge == null
          ? 'Once submitted, the challenge will be created.'
          : 'Once submitted, the changes cannot be undone.',
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
            Navigator.of(context).pop();
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();

              _initialCode = codeLineController.text;

              DebuggingChallenge challenge = DebuggingChallenge(
                id: widget.challenge?.id ?? _title.toSnakeCase(),
                title: _title,
                instructions: _instructions,
                initialCode: _initialCode,
                correctLine: _correctLine,
                expectedOutput: _expectedOutput,
                attemptsLeft: _attemptsAllowed,
                duration: _duration,
              );

              try {
                await DebuggingChallengeService().createDebuggingChallenge(
                  challenge,
                  ref.read(appUserNotifierProvider).value!.orgId!,
                );

                if (mounted) {
                  Utils.displayDialog(
                    context: context,
                    title: 'Success!',
                    content: widget.challenge == null
                        ? 'Debugging Challenge created successfully'
                        : 'Debugging Challenge updated successfully',
                    lottieAsset: 'assets/anim/congrats.json',
                    onDismiss: () {
                      ref.read(screenProvider.notifier).popScreen();
                    },
                  );
                }
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
                if (mounted) {
                  Utils.displayDialog(
                    context: context,
                    title: 'Error',
                    content: widget.challenge == null
                        ? 'An error occurred while creating the debugging challenge'
                        : 'An error occurred while updating the debugging challenge',
                    lottieAsset: 'assets/anim/error.json',
                    onDismiss: () {
                      ref.read(screenProvider.notifier).popScreen();
                    },
                  );
                }
              }
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
