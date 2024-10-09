import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/models/debugging_challenge.dart';
import 'package:codecraft/services/debugging_challenge_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';

class CreateDebuggingChallengeScreen extends ConsumerStatefulWidget {
  const CreateDebuggingChallengeScreen({super.key});

  @override
  _CreateDebuggingChallengeScreenState createState() =>
      _CreateDebuggingChallengeScreenState();
}

class _CreateDebuggingChallengeScreenState
    extends ConsumerState<CreateDebuggingChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final CodeLineEditingController controller = CodeLineEditingController();

  String _duration = DateTime.now().add(const Duration(days: 1)).toString();
  final BoardDateTimeTextController dateTimeController =
      BoardDateTimeTextController();
  int _currentStep = 0;

  String _title = '';
  String _instructions = '';
  String _initialCode = '';
  int _correctLine = 1;
  String _expectedOutput = '';
  int _attemptsAllowed = 3;

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
                _formKey.currentState!.save();
                _initialCode = controller.text;
                _submitDebuggingChallenge();
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
              content: _buildSolutionStep(),
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
          decoration: const InputDecoration(
            labelText: 'Title',
            prefix: Icon(Icons.title),
          ),
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
          decoration: const InputDecoration(labelText: 'Instructions'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
          controller: controller,
        ),
      ),
    );
  }

  Widget _buildCorrectLineStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: const InputDecoration(labelText: 'Correct Line Number'),
          keyboardType: TextInputType.number,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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

  Widget _buildSolutionStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: const InputDecoration(labelText: 'Expected Output'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLines: 3,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the expected output.';
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
          decoration: const InputDecoration(labelText: 'Attempts Allowed'),
          keyboardType: TextInputType.number,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: _attemptsAllowed.toString(),
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

  void _submitDebuggingChallenge() async {
    Utils.displayDialog(
      context: context,
      title: 'Are you sure?',
      content: 'Once submitted, the changes cannot be undone',
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

              _initialCode = controller.text;

              DebuggingChallenge updatedChallenge = DebuggingChallenge(
                id: _title.toSnakeCase(),
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
                  updatedChallenge,
                  ref.read(appUserNotifierProvider).value!.orgId!,
                );

                if (mounted) {
                  Utils.displayDialog(
                    context: context,
                    title: 'Success!',
                    content: 'Debugging Challenge updated successfully',
                    lottieAsset: 'assets/anim/congrats.json',
                    onDismiss: () {
                      ref.read(screenProvider.notifier).popScreen();
                    },
                  );
                }
              } catch (e) {
                if (mounted) {
                  Utils.displayDialog(
                    context: context,
                    title: 'Error',
                    content:
                        'An error occurred while updating the debugging challenge',
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