import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:codecraft/widgets/codeblocks/code_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/providers/code_execution_provider.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:codecraft/widgets/screentypes/split_screen.dart';
import 'package:codecraft/widgets/viewers/markdown_viewer.dart';
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
    _initializeChallenge();
  }

  void _initializeChallenge() {
    _returnType = _getReturnType();
    _codeController.text = widget.challenge.sampleCode ??
        generateSampleCode('java', widget.challenge);
  }

  String _getReturnType() {
    switch (widget.challenge.unitTests[0].expectedOutput.type) {
      case 'String':
        return 'String';
      case 'Integer':
        return 'int';
      case 'Double':
        return 'double';
      case 'Boolean':
        return 'boolean';
      default:
        return 'void';
    }
  }

  void _runCode() {
    final codeExecution = ref.read(codeExecutionProvider.notifier);
    codeExecution.executeCode(
      _codeController.text,
      widget.challenge.unitTests,
      widget.challenge.className,
      _selectedLanguage,
      widget.challenge.methodName,
    );
  }

  void _submitCode() async {
    final codeExecution = ref.watch(codeExecutionProvider.notifier);
    if (await codeExecution.allTestsPassed(
        _codeController.text,
        widget.challenge.unitTests,
        widget.challenge.className,
        _selectedLanguage,
        widget.challenge.methodName)) {
      await ChallengeService().markChallengeAsCompleted(widget.challenge.id);
      ref
          .read(appUserNotifierProvider.notifier)
          .addExperience(widget.challenge.experienceToEarn);
      if (!mounted) return;
      Utils.displayDialog(
        context: context,
        title: 'Challenge Completed!',
        content: 'Your code passed all the test cases.',
        lottieAsset: 'assets/anim/congrats.json',
        onDismiss: () => Navigator.of(context).pop(),
      );
    } else {
      if (!mounted) return;
      Utils.displayDialog(
        context: context,
        title: 'Challenge Failed!',
        content: 'Your code did not pass all the test cases.',
        lottieAsset: 'assets/anim/failed.json',
        onDismiss: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String output = ref.watch(codeExecutionProvider).output;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coding Challenge',
          style: TextStyle(
              color: ThemeUtils.getTextColor(Theme.of(context).primaryColor)),
        ),
      ),
      body: DraggableSplitScreen(
        leftWidget: _buildLeftPanel(output),
        rightWidget: _buildRightPanel(),
      ),
    );
  }

  Widget _buildLeftPanel(String output) {
    return DraggableSplitScreen(
      isVertical: true,
      leftWidget: _buildInstructionsCard(),
      rightWidget: _buildOutputCard(output),
    );
  }

  Widget _buildRightPanel() {
    return Stack(
      children: [
        _buildCodeEditorCard(),
        Positioned(
          top: 36,
          right: 20,
          child: DropdownButton<String>(
            value: _selectedLanguage,
            dropdownColor: Colors.grey[800],
            style: const TextStyle(color: Colors.white),
            items: ['java', 'python'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedLanguage = newValue!;
                _codeController.text =
                    generateSampleCode(_selectedLanguage, widget.challenge);
              });
            },
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: _buildActionButtons(),
        ),
      ],
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Instructions',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Expanded(
              child: MarkdownViewer(
                markdownData: widget.challenge.instructions,
                displayToc: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputCard(String output) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Output',
                    style: Theme.of(context).textTheme.headlineSmall),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref.read(codeExecutionProvider.notifier).resetOutput();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: CodeWrapperWidget(
                  output.isEmpty ? 'No output' : output,
                  'txt',
                  theme: SyntaxTheme.dracula,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeEditorCard() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: CodeEditorWidget(
              selectedLanguage:
                  _selectedLanguage == 'java' ? langJava : langPython,
              controller: _codeController,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: _runCode,
            child: const Text('Run Code'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _submitCode,
            child: const Text('Submit Code'),
          ),
        ],
      ),
    );
  }

  String generateSampleCode(String language, Challenge challenge) {
    String className = challenge.className;
    String methodName = challenge.methodName;
    String returnType = _returnType;

    String javaArgs = challenge.unitTests[0].input[0].type.isEmpty
        ? ''
        : challenge.unitTests[0].input
            .map((e) =>
                '${e.type} arg${challenge.unitTests[0].input.indexOf(e)}')
            .join(', ');

    String pythonArgs = challenge.unitTests[0].input[0].type.isEmpty
        ? ''
        : challenge.unitTests[0].input
            .map((e) => 'arg${challenge.unitTests[0].input.indexOf(e)}')
            .join(', ');

    if (language == 'java') {
      return '''
class $className {
  public $returnType $methodName($javaArgs) {
    // Your code here
  }
}
''';
    } else if (language == 'python') {
      return '''
class $className:
  def $methodName($pythonArgs):
    # Your code here
    pass
''';
    }
    return '';
  }
}
