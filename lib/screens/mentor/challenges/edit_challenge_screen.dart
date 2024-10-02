import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/models/expected_output.dart';
import 'package:codecraft/models/input.dart';
import 'package:codecraft/models/unit_test.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:re_editor/re_editor.dart';

class EditChallengeScreen extends ConsumerStatefulWidget {
  final Challenge challenge;
  const EditChallengeScreen({super.key, required this.challenge});

  @override
  _EditChallengeScreenState createState() => _EditChallengeScreenState();
}

class _EditChallengeScreenState extends ConsumerState<EditChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final CodeLineEditingController controller = CodeLineEditingController();
  final BoardDateTimeTextController dateTimeController =
      BoardDateTimeTextController();
  int _currentStep = 0;

  late String _instructions;
  late String _sampleCode;
  late String _className;
  late String _methodName;
  late String _duration;
  late List<UnitTest> _unitTests;

  @override
  void initState() {
    super.initState();

    _instructions = widget.challenge.instructions;
    _sampleCode = widget.challenge.sampleCode!;
    controller.text = _sampleCode;
    _duration = widget.challenge.duration;
    _className = widget.challenge.className;
    _methodName = widget.challenge.methodName;
    _unitTests = widget.challenge.unitTests;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Edit Challenge',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'You are editing challenge ${widget.challenge.id}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
              Form(
                key: _formKey,
                child: Stepper(
                  currentStep: _currentStep,
                  onStepCancel: () {
                    if (_currentStep == 0) {
                      ref.watch(screenProvider.notifier).popScreen();
                    }

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
                    if (_currentStep < 5 && _formKey.currentState != null) {
                      setState(() {
                        _currentStep += 1;
                      });

                      return;
                    }

                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      _sampleCode = controller.text;
                      Utils.displayDialog(
                        context: context,
                        title: 'Are you sure about your changes?',
                        content:
                            "You are about to update the challenge ${widget.challenge.id} with the new changes.\n Are you sure you want to proceed?",
                        lottieAsset: 'assets/anim/question.json',
                        actions: [
                          IconsButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            text: 'No, go back.',
                            iconData: Icons.close,
                            iconColor: Colors.white,
                            color: Colors.red,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          IconsButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _submitChallenge();
                            },
                            text: 'Proceed with changes',
                            iconData: Icons.check,
                            iconColor: Colors.white,
                            color: Colors.green,
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        onDismiss: () =>
                            ref.watch(screenProvider.notifier).popScreen(),
                      );
                    }
                  },
                  steps: [
                    Step(
                      title: const Text('Instructions'),
                      content: _buildInstructionsStep(),
                      isActive: _currentStep >= 0,
                      state: _currentStep == 0
                          ? StepState.editing
                          : StepState.complete,
                    ),
                    Step(
                      title: const Text('Sample Code'),
                      content: _buildSampleCodeStep(),
                      isActive: _currentStep >= 1,
                      state: _currentStep == 1
                          ? StepState.editing
                          : StepState.complete,
                    ),
                    Step(
                      title: const Text('Class Name'),
                      content: _buildClassNameStep(),
                      isActive: _currentStep >= 2,
                      state: _currentStep == 2
                          ? StepState.editing
                          : StepState.complete,
                    ),
                    Step(
                      title: const Text('Method Name'),
                      content: _buildMethodNameStep(),
                      isActive: _currentStep >= 3,
                      state: _currentStep == 3
                          ? StepState.editing
                          : StepState.complete,
                    ),
                    Step(
                      title: const Text('Deadline'),
                      content: _buildDurationStep(),
                      isActive: _currentStep >= 4,
                      state: _currentStep == 4
                          ? StepState.editing
                          : StepState.complete,
                    ),
                    Step(
                      title: const Text('Unit Tests'),
                      content: _buildUnitTestsStep(),
                      isActive: _currentStep >= 5,
                      state: _currentStep == 5
                          ? StepState.editing
                          : StepState.complete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionsStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          initialValue: _instructions,
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

  Widget _buildSampleCodeStep() {
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

  Widget _buildClassNameStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          initialValue: _className,
          decoration: const InputDecoration(labelText: 'Class Name'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the class name';
            }
            return null;
          },
          onSaved: (value) {
            _className = value!;
          },
        ),
      ),
    );
  }

  Widget _buildMethodNameStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          initialValue: _methodName,
          decoration: const InputDecoration(labelText: 'Method Name'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the method name';
            }
            return null;
          },
          onSaved: (value) {
            _methodName = value!;
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
          autofocus: true,
          pickerType: DateTimePickerType.datetime,
          initialDate: _duration.toDateTime(),
          minimumDate: DateTime.now(),
          maximumDate: DateTime.now().add(const Duration(days: 365)),
          options: const BoardDateTimeOptions(
            inputable: false,
          ),
          textStyle: Theme.of(context).textTheme.bodyMedium,
          onChanged: (date) {
            _duration = date.toIso8601String();
          },
        ),
      ),
    );
  }

  Widget _buildUnitTestsStep() {
    return Card(
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            itemCount: _unitTests.length,
            padding: const EdgeInsets.symmetric(vertical: 5),
            itemBuilder: (context, index) {
              return _buildUnitTestTile(index);
            },
          ),
          TextButton(
            onPressed: _addUnitTest,
            child: const Text('Add Unit Test'),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitTestTile(int index) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Unit Test ${index + 1}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      _unitTests.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _unitTests[index].input.length,
              itemBuilder: (context, inputIndex) {
                return Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Input ${inputIndex + 1} Value'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: _unitTests[index].input[inputIndex].value,
                      onSaved: (value) {
                        _unitTests[index].input[inputIndex].value = value ?? '';
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'Input ${inputIndex + 1} Type'),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      initialValue: _unitTests[index].input[inputIndex].type,
                      onSaved: (value) {
                        _unitTests[index].input[inputIndex].type = value ?? '';
                      },
                    ),
                  ],
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _unitTests[index].input.add(Input(value: '', type: ''));
                });
              },
              child: const Text('Add Input'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Expected Output Value'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              initialValue: _unitTests[index].expectedOutput.value,
              onSaved: (value) {
                _unitTests[index].expectedOutput.value = value ?? '';
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Expected Output Type'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              initialValue: _unitTests[index].expectedOutput.type,
              onSaved: (value) {
                _unitTests[index].expectedOutput.type = value ?? '';
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addUnitTest() {
    setState(() {
      _unitTests.add(
        UnitTest(
          input: [Input(value: '', type: '')],
          expectedOutput: ExpectedOutput(
            value: '',
            type: '',
          ),
        ),
      );
    });
  }

  Future<void> _submitChallenge() async {
    final challenge = Challenge(
      id: widget.challenge.id,
      instructions: _instructions,
      sampleCode: _sampleCode,
      className: _className,
      methodName: _methodName,
      duration: _duration,
      unitTests: _unitTests,
    );

    await ChallengeService().createChallenge(
      challenge,
      ref.read(appUserNotifierProvider).value!.orgId!,
    );

    if (!mounted) {
      return;
    }

    ref.read(screenProvider.notifier).popScreen();
  }
}
