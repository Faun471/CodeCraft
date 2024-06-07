import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/providers/code_execution_provider.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:codecraft/widgets/screentypes/split_screen.dart';
import 'package:codecraft/widgets/viewers/markdown_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/python.dart';

class ChallengeScreen extends ConsumerStatefulWidget {
  final Challenge challenge;

  const ChallengeScreen({super.key, required this.challenge});

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen> {
  final CodeLineEditingController _codeController = CodeLineEditingController();
  String _selectedLanguage = 'java';
  String _returnType = 'String';

  @override
  void initState() {
    super.initState();
    switch (widget.challenge.unitTests[0].expectedOutput.type) {
      case 'String':
        _returnType = 'String';
        break;
      case 'Integer':
        _returnType = 'int';
        break;
      case 'Double':
        _returnType = 'double';
        break;
      case 'Boolean':
        _returnType = 'boolean';
        break;
      default:
        _returnType = 'void';
    }

    if (widget.challenge.sampleCode == null ||
        widget.challenge.sampleCode!.isEmpty) {
      _codeController.text = generateSampleCode(widget.challenge.className,
          widget.challenge.methodName, _selectedLanguage, _returnType);
    } else {
      _codeController.text = widget.challenge.sampleCode!;
    }
  }

  void _submitCode() async {
    final codeExecution = ref.watch(codeExecutionProvider.notifier);
    final script = _codeController.text;

    if (await codeExecution.allTestsPassed(
        script,
        widget.challenge.unitTests,
        widget.challenge.className,
        _selectedLanguage,
        widget.challenge.methodName)) {
      await ChallengeService().markChallengeAsCompleted(widget.challenge.id);

      if (!mounted) {
        return;
      }

      await ref.read(appUserNotifierProvider.notifier).levelUp();
    }
  }

  void _onLanguageChanged(String? newValue) {
    setState(() {
      _selectedLanguage = newValue!;
      _codeController.text = generateSampleCode(widget.challenge.className,
          widget.challenge.methodName, _selectedLanguage, _returnType);
    });
  }

  @override
  Widget build(BuildContext context) {
    String output = ref.watch(codeExecutionProvider).output;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coding Challenge'),
      ),
      body: Stack(
        children: [
          DraggableSplitScreen(
            leftWidget: Column(
              children: [
                Expanded(
                  child: DraggableSplitScreen(
                    isVertical: true,
                    leftWidget: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MarkdownViewer(
                          markdownData: widget.challenge.instructions,
                          displayToc: false,
                        )),
                    rightWidget: Column(
                      children: [
                        Text('Output:',
                            style: Theme.of(context).textTheme.displayLarge!),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child:
                                    Text(output.isEmpty ? 'No output' : output),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            rightWidget: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: const Color.fromARGB(255, 30, 30, 30),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: CodeEditorWidget(
                        selectedLanguage:
                            _selectedLanguage == 'java' ? langJava : langPython,
                        controller: _codeController,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 32,
            child: DropdownButton<String>(
              style: const TextStyle(
                fontSize: 12,
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              value: _selectedLanguage,
              dropdownColor: const Color.fromARGB(255, 30, 30, 30),
              items: <String>['java', 'python'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                      )),
                );
              }).toList(),
              onChanged: _onLanguageChanged,
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _submitCode,
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

String generateSampleCode(
    String className, String methodName, String language, String returnType) {
  if (language == 'java') {
    return '''
class $className {
  public $returnType $methodName() {
    // Your code here
  }
}
''';
  } else if (language == 'python') {
    return '''
class $className:
  def $methodName(self):
    # Your code here
    pass
''';
  }
  return '';
}
