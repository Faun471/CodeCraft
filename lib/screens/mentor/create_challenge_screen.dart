import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:logging/logging.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  _CreateChallengeScreenState createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  String _instructions = '';
  String _sampleCode = '';
  String _className = '';
  final List<UnitTest> _unitTests = [
    UnitTest(
        input: '',
        expectedOutput: ExpectedOutput(
          value: '',
          type: '',
        ),
        methodName: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a New Challenge'),
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() {
              _currentStep += 1;
            });
          } else {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              _submitChallenge();
            }
          }
        },
        steps: [
          Step(
            title: const Text('Instructions'),
            content: _buildInstructionsStep(),
            isActive: _currentStep >= 0,
            state: _currentStep == 0 ? StepState.editing : StepState.complete,
          ),
          Step(
            title: const Text('Sample Code'),
            content: _buildSampleCodeStep(),
            isActive: _currentStep >= 1,
            state: _currentStep == 1 ? StepState.editing : StepState.complete,
          ),
          Step(
            title: const Text('Class Name'),
            content: _buildClassNameStep(),
            isActive: _currentStep >= 2,
            state: _currentStep == 2 ? StepState.editing : StepState.complete,
          ),
          Step(
            title: const Text('Unit Tests'),
            content: _buildUnitTestsStep(),
            isActive: _currentStep >= 3,
            state: _currentStep == 3 ? StepState.editing : StepState.complete,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          decoration: const InputDecoration(labelText: 'Sample Code'),
          maxLines: 10,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter the sample code';
            }
            return null;
          },
          onSaved: (value) {
            _sampleCode = value!;
          },
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
            TextFormField(
              decoration: const InputDecoration(labelText: 'Method Name'),
              initialValue: _unitTests[index].methodName,
              onSaved: (value) {
                _unitTests[index].methodName = value!;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Input'),
              initialValue: _unitTests[index].input,
              onSaved: (value) {
                _unitTests[index].input = value!;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Expected Output Value'),
              initialValue: _unitTests[index].expectedOutput.value,
              onSaved: (value) {
                _unitTests[index].expectedOutput.value = value!;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Expected Output Type'),
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
            methodName: ''),
      );
    });
  }

  Future<void> _submitChallenge() async {
    final challenge = Challenge(
      id: Utils.toSnakeCase(_className),
      instructions: _instructions,
      sampleCode: _sampleCode,
      className: _className,
      unitTests: _unitTests,
    );

    Logger('Create Challenge').info(challenge.toJson());

    await ChallengeService()
        .createChallenge(challenge, AppUser.instance.data['orgId'] ?? '');

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }
}
