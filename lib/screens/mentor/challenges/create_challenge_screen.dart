import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/expected_output.dart';
import 'package:codecraft/models/input.dart';
import 'package:codecraft/models/unit_test.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:re_editor/re_editor.dart';

class CreateChallengeScreen extends ConsumerStatefulWidget {
  final Challenge? challenge;

  const CreateChallengeScreen({super.key, this.challenge});

  @override
  _CreateChallengeScreenState createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends ConsumerState<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final CodeLineEditingController controller = CodeLineEditingController();

  String _duration = DateTime.now().add(const Duration(days: 1)).toString();
  int _currentStep = 0;

  String _instructions = '';
  String _sampleCode = '';
  String _className = '';
  String _methodName = '';
  List<UnitTest> _unitTests = [
    UnitTest(
      input: [Input(value: '', type: '')],
      expectedOutput: ExpectedOutput(
        value: '',
        type: '',
      ),
    ),
  ];

  final fields = <int, Key>{
    0: Key('instructions'),
    1: Key('sampleCode'),
    2: Key('className'),
    3: Key('methodName'),
    4: Key('duration'),
    5: Key('unitTests'),
  };

  @override
  void initState() {
    super.initState();

    if (widget.challenge != null) {
      _instructions = widget.challenge!.instructions;
      _sampleCode = widget.challenge!.sampleCode ?? '';
      controller.text = _sampleCode;
      _className = widget.challenge!.className;
      _methodName = widget.challenge!.methodName;
      _unitTests = widget.challenge!.unitTests;
      _duration = widget.challenge!.duration;
    }
  }

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
          key: fields[0],
          decoration: const InputDecoration(labelText: 'Instructions'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          maxLines: 5,
          initialValue: _instructions,
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
          key: fields[1],
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
          key: fields[2],
          decoration: const InputDecoration(labelText: 'Class Name'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: _className,
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
          key: fields[3],
          decoration: const InputDecoration(labelText: 'Method Name'),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: _methodName,
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

  void _addOrEditUnitTest({int? index}) {
    List<Input> inputs = index != null
        ? _unitTests[index].input
        : [Input(value: '', type: 'String')];

    String expectedOutputValue =
        index != null ? _unitTests[index].expectedOutput.value : '';

    String expectedOutputType =
        index != null ? _unitTests[index].expectedOutput.type : 'String';
    final List<String> availableTypes = ['String', 'int', 'double', 'boolean'];

    final formKey = GlobalKey<FormState>();

    Utils.scrollableMaterialDialog(
      context: context,
      title: index != null ? 'Edit Unit Test' : 'Add Unit Test',
      customViewPosition: CustomViewPosition.BEFORE_ACTION,
      customView: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Form(
            key: formKey,
            child: Column(
              children: [
                ...inputs.asMap().entries.map((entry) {
                  int inputIndex = entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: inputs[inputIndex].type == 'boolean'
                              ? DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                      labelText:
                                          'Input Value ${inputIndex + 1}'),
                                  value: inputs[inputIndex].value == 'true'
                                      ? 'true'
                                      : 'false',
                                  items: ['true', 'false'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      inputs[inputIndex].value =
                                          newValue ?? 'true';
                                    });
                                  },
                                )
                              : TextFormField(
                                  decoration: InputDecoration(
                                      labelText:
                                          'Input Value ${inputIndex + 1}'),
                                  initialValue: inputs[inputIndex].value,
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter a value'
                                      : null,
                                  onChanged: (value) =>
                                      inputs[inputIndex].value = value,
                                ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                                labelText: 'Input Type ${inputIndex + 1}'),
                            value: inputs[inputIndex].type.isEmpty
                                ? 'String'
                                : inputs[inputIndex].type,
                            items: availableTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (String? newType) {
                              setState(() {
                                if (newType == 'boolean') {
                                  inputs[inputIndex].value = 'true';
                                }

                                inputs[inputIndex].type = newType ?? 'String';
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.remove,
                            color: ThemeUtils.getTextColorForBackground(
                                Theme.of(context).scaffoldBackgroundColor),
                          ),
                          onPressed: () {
                            setState(() => inputs.removeAt(inputIndex));
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(
                      () => inputs.add(Input(value: '', type: 'String'))),
                  child: Text(
                    'Add Input',
                    style: TextStyle(
                        color: ThemeUtils.getTextColorForBackground(
                            Theme.of(context).primaryColor)),
                  ),
                ),
                const SizedBox(height: 16),
                expectedOutputType == 'boolean'
                    ? DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            labelText: 'Expected Output Value'),
                        value: expectedOutputValue == 'true' ? 'true' : 'false',
                        items: ['true', 'false'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            expectedOutputValue = newValue ?? 'true';
                          });
                        },
                      )
                    : TextFormField(
                        decoration: const InputDecoration(
                            labelText: 'Expected Output Value'),
                        initialValue: expectedOutputValue,
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter a value' : null,
                        onChanged: (value) => expectedOutputValue = value,
                      ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Expected Output Type'),
                  value: expectedOutputType.isEmpty
                      ? 'String'
                      : expectedOutputType,
                  items: availableTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  validator: (value) =>
                      value == null ? 'Please select a type' : null,
                  onChanged: (String? newType) {
                    setState(() {
                      expectedOutputValue =
                          newType == 'boolean' ? 'true' : expectedOutputValue;
                      expectedOutputType = newType ?? 'String';
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text(index != null ? 'Save' : 'Add'),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();

              setState(() {
                if (index != null) {
                  _unitTests[index] = UnitTest(
                    input: inputs,
                    expectedOutput: ExpectedOutput(
                        value: expectedOutputValue, type: expectedOutputType),
                  );
                } else {
                  _unitTests.add(UnitTest(
                    input: inputs,
                    expectedOutput: ExpectedOutput(
                        value: expectedOutputValue, type: expectedOutputType),
                  ));
                }
              });
              Navigator.of(context).pop();
            } else {
              Utils.displayDialog(
                context: context,
                title: 'Error',
                content: 'Please fill in all the required fields.',
                lottieAsset: 'assets/anim/error.json',
              );
            }
          },
        ),
      ],
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
              return ListTile(
                title: Text('Unit Test ${index + 1}'),
                subtitle: Text(
                    'Input: ${inputToString(_unitTests[index].input)}, Expected: ${expectedOutputToString(_unitTests[index].expectedOutput)}'),
                trailing: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditUnitTest(index: index),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            setState(() => _unitTests.removeAt(index)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextButton(
              onPressed: () => _addOrEditUnitTest(),
              child: const Text('Add Unit Test'),
            ),
          ),
        ],
      ),
    );
  }

  String inputToString(List<Input> inputs) {
    return inputs.map((input) => input.value).join(',');
  }

  String expectedOutputToString(ExpectedOutput output) {
    switch (output.type) {
      case 'String':
        return '"${output.value}"';
      case 'boolean':
        return output.value == 'true' ? 'true' : 'false';
      case 'char':
        return "'${output.value}'";
      default:
        return output.value;
    }
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

  Future<void> _submitChallenge() async {
    Utils.displayDialog(
      context: context,
      title: 'Are you sure with the changes?',
      content: 'Please review the changes before submitting.',
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
            final challenge = Challenge(
              id: _className.toSnakeCase(),
              instructions: _instructions,
              sampleCode: _sampleCode,
              className: _className,
              methodName: _methodName,
              unitTests: _unitTests,
              duration: _duration,
            );
            try {
              await ChallengeService().createChallenge(
                challenge,
                ref.read(appUserNotifierProvider).value!.orgId!,
              );
            } on FirebaseException catch (e) {
              if (!mounted) return;

              if (e.code == 'permission-denied') {
                Utils.displayDialog(
                  context: context,
                  title: 'Permission Denied',
                  content:
                      'You do not have permission to create a challenge.\nPlease check if your plan is still active.',
                  lottieAsset: 'assets/anim/error.json',
                );
                return;
              }
            } on Exception catch (e) {
              if (!mounted) return;
              if (e.toString().contains(
                  'Organization has reached the maximum number of apprentices')) {
                Utils.displayDialog(
                  context: context,
                  title: 'Error',
                  content:
                      'Organization has reached the maximum number of apprentices.\nPlease upgrade your plan, or remove some apprentices.',
                  lottieAsset: 'assets/anim/error.json',
                );
                return;
              }
            }

            ref.read(screenProvider.notifier).popScreen();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
