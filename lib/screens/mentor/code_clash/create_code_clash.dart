import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/models/expected_output.dart';
import 'package:codecraft/models/input.dart';
import 'package:codecraft/models/unit_test.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/services/code_clash_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:re_editor/re_editor.dart';

class CreateCodeClashScreen extends ConsumerStatefulWidget {
  final CodeClash? codeClash;

  const CreateCodeClashScreen({super.key, this.codeClash});

  @override
  _EditCodeClashScreenState createState() => _EditCodeClashScreenState();
}

class _EditCodeClashScreenState extends ConsumerState<CreateCodeClashScreen> {
  final _formKey = GlobalKey<FormState>();
  final CodeLineEditingController codeController = CodeLineEditingController();

  int _currentStep = 0;
  String _title = '';
  String _instructions = '';
  String _sampleCode = '';
  String _className = '';
  String _methodName = '';
  int _timeLimit = 60;
  List<UnitTest> _unitTests = [];

  final fields = <int, List<Key>>{
    0: [Key('title')],
    1: [Key('instructions')],
    2: [Key('sampleCode')],
    3: [Key('className'), Key('methodName')],
    4: [Key('timeLimit')],
  };

  @override
  void initState() {
    super.initState();
    if (widget.codeClash != null) {
      _loadCodeClash();
    }
  }

  void _loadCodeClash() {
    _title = widget.codeClash!.title;
    _instructions = widget.codeClash!.instructions;
    _sampleCode = widget.codeClash!.sampleCode ?? '';
    codeController.text = _sampleCode;
    _className = widget.codeClash!.className;
    _methodName = widget.codeClash!.methodName;
    _timeLimit = widget.codeClash!.timeLimit;
    _unitTests = widget.codeClash!.unitTests;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: () async {
          if (_currentStep < 5) {
            setState(() => _currentStep += 1);
          } else {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              await _submitCodeClash();
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
                          (entry) => entry.value.contains(firstInvalidStep),
                          orElse: () => MapEntry(0, []),
                        )
                        .key;
                  });
                },
              );
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            _cancelChallenge();
          }
        },
        onStepTapped: (int index) {
          setState(() => _currentStep = index);
        },
        steps: [
          Step(
            title: const Text('Basic Info'),
            content: _buildBasicInfoStep(),
            isActive: _currentStep >= 0,
          ),
          Step(
            title: const Text('Instructions'),
            content: _buildInstructionsStep(),
            isActive: _currentStep >= 1,
          ),
          Step(
            title: const Text('Sample Code'),
            content: _buildSampleCodeStep(),
            isActive: _currentStep >= 2,
          ),
          Step(
            title: const Text('Class and Method'),
            content: _buildClassMethodStep(),
            isActive: _currentStep >= 3,
          ),
          Step(
            title: const Text('Time Settings'),
            content: _buildTimeSettingsStep(),
            isActive: _currentStep >= 4,
          ),
          Step(
            title: const Text('Unit Tests'),
            content: _buildUnitTestsStep(),
            isActive: _currentStep >= 5,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              key: fields[0]!.first,
              initialValue: _title,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a title' : null,
              onSaved: (value) => _title = value!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          key: fields[1]!.first,
          initialValue: _instructions,
          decoration: const InputDecoration(labelText: 'Instructions'),
          maxLines: 5,
          validator: (value) =>
              value!.isEmpty ? 'Please enter instructions' : null,
          onSaved: (value) => _instructions = value!,
        ),
      ),
    );
  }

  Widget _buildSampleCodeStep() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 300,
        child: CodeEditorWidget(
          key: fields[2]!.first,
          controller: codeController,
        ),
      ),
    );
  }

  Widget _buildClassMethodStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              key: fields[3]!.first,
              initialValue: _className,
              decoration: const InputDecoration(labelText: 'Class Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a class name' : null,
              onSaved: (value) => _className = value!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: fields[3]!.last,
              initialValue: _methodName,
              decoration: const InputDecoration(labelText: 'Method Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a method name' : null,
              onSaved: (value) => _methodName = value!,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSettingsStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              key: fields[4]!.first,
              initialValue: _timeLimit.toString(),
              decoration:
                  const InputDecoration(labelText: 'Time Limit (minutes)'),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (value) => int.tryParse(value!) == null
                  ? 'Please enter a valid number'
                  : null,
              onSaved: (value) => _timeLimit = int.parse(value!),
            ),
          ],
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
      case 'bool':
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

  Future<void> _submitCodeClash() async {
    _sampleCode = codeController.text;

    Utils.displayDialog(
      context: context,
      title: 'Are you sure about your changes?',
      content: "Please review the changes before submitting?",
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
          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        IconsButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              CodeClash updatedCodeClash = CodeClash(
                id: widget.codeClash?.id ?? _title.toSnakeCase(),
                title: _title,
                instructions: _instructions,
                sampleCode: _sampleCode,
                className: _className,
                methodName: _methodName,
                timeLimit: _timeLimit,
                unitTests: _unitTests,
                status: 'pending',
              );

              await CodeClashService().createCodeClash(
                updatedCodeClash,
                ref.read(appUserNotifierProvider).requireValue.orgId!,
              );
            } on FirebaseException catch (e) {
              if (!mounted) return;

              if (e.code == 'permission-denied') {
                Utils.displayDialog(
                  context: context,
                  title: 'Permission Denied',
                  content:
                      'You do not have permission to create a code clash.\nPlease check if your plan is still active.',
                  lottieAsset: 'assets/anim/error.json',
                );
                return;
              }
            } catch (e) {
              if (!mounted) return;
              Utils.displayDialog(
                context: context,
                title: 'Error',
                content: e.toString(),
                lottieAsset: 'assets/anim/error.json',
              );
            }

            ref.read(screenProvider.notifier).popScreen();
          },
          text: 'Yes, proceed.',
          iconData: Icons.check,
          iconColor: Colors.white,
          color: Colors.green,
          textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}
