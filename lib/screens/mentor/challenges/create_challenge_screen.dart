import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:re_editor/re_editor.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  _CreateChallengeScreenState createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final CodeLineEditingController controller = CodeLineEditingController();

  String _duration = DateTime.now().add(const Duration(days: 1)).toString();
  final BoardDateTimeTextController dateTimeController =
      BoardDateTimeTextController();
  int _currentStep = 0;

  String _instructions = '';
  String _sampleCode = '';
  String _className = '';
  String _methodName = '';
  List<UnitTest> _unitTests = [
    UnitTest(
      input: '',
      expectedOutput: ExpectedOutput(
        value: '',
        type: '',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            children: [
              Form(
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

                      _submitChallenge();
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
            TextFormField(
              decoration: const InputDecoration(labelText: 'Input'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              initialValue: _unitTests[index].input,
              onSaved: (value) {
                _unitTests[index].input = value!;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Expected Output Value'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              initialValue: _unitTests[index].expectedOutput.value,
              onSaved: (value) {
                _unitTests[index].expectedOutput.value = value!;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Expected Output Type'),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              initialValue: _unitTests[index].expectedOutput.type,
              onSaved: (value) {
                _unitTests[index].expectedOutput.type = value!;
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
          input: '',
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
      id: _className.toSnakeCase(),
      instructions: _instructions,
      sampleCode: _sampleCode,
      className: _className,
      methodName: _methodName,
      unitTests: _unitTests,
      duration: _duration,
    );

    Logger('Create Challenge').info(challenge.toJson());

    await ChallengeService().createChallenge(challenge,
        ref.read(appUserNotifierProvider).value!.data['orgId'] ?? '');

    if (!mounted) {
      return;
    }

    _resetChallenge();
  }

  void _resetChallenge() {
    setState(() {
      _className = '';
      _methodName = '';
      _instructions = '';
      _sampleCode = '';
      _unitTests = [];
      _currentStep = 0;
    });
  }
}