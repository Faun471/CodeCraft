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
import 'package:video_player/video_player.dart';

class ChallengeScreen extends ConsumerStatefulWidget {
  final Challenge challenge;
  final VoidCallback? onChallengeCompleted;

  const ChallengeScreen({
    super.key,
    required this.challenge,
    this.onChallengeCompleted,
  });

  @override
  _ChallengeScreenState createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends ConsumerState<ChallengeScreen> {
  final CodeLineEditingController _codeController = CodeLineEditingController();
  String _selectedLanguage = 'java';
  String _returnType = 'String';

  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    _initializeChallenge();
    if (widget.challenge.introAnimation != null) {
      _initializeVideoController(widget.challenge.introAnimation!);
    }
  }

  void _initializeChallenge() {
    _returnType = _getReturnType();

    if (widget.challenge.sampleCode != null &&
        widget.challenge.sampleCode!.isNotEmpty) {
      print('sample code: ${widget.challenge.sampleCode}');
      _codeController.text = widget.challenge.sampleCode!;
      return;
    }

    _codeController.text =
        generateSampleCode(_selectedLanguage, widget.challenge);
  }

  void _initializeVideoController(String videoUrl) {
    controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      httpHeaders: {
        'Cache-Control': 'max-age=3600',
      },
    )..initialize().then((_) {
        if (controller.value.isInitialized) {
          setState(() {
            _showVideoDialog();
          });
        }
      });

    controller.addListener(() {
      if (controller.value.position == controller.value.duration) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showVideoDialog() {
    if (controller.value.isInitialized) {
      showDialog(
        context: context,
        builder: (_) => _buildVideoDialog(),
      );
    }
  }

  Widget _buildVideoDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: VideoPlayer(controller),
                      )
                    : const Center(child: CircularProgressIndicator()),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        controller.value.isPlaying
                            ? controller.pause()
                            : controller.play();
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getReturnType() {
    switch (widget.challenge.unitTests.first.expectedOutput.type) {
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

  Future<void> _submitCode() async {
    final codeExecution = ref.read(codeExecutionProvider.notifier);

    final allPassed = await codeExecution.allTestsPassed(
      _codeController.text,
      widget.challenge.unitTests,
      widget.challenge.className,
      _selectedLanguage,
      widget.challenge.methodName,
    );

    if (allPassed) {
      if (!mounted) return;
      _handleChallengeSuccess(context);

      final appUser = ref.watch(appUserNotifierProvider).value!;

      final completedChallenges = appUser.completedChallenges ?? <String>[];

      if (completedChallenges.contains(widget.challenge.id)) {
        return;
      }

      await ChallengeService().markChallengeAsCompleted(widget.challenge.id);
      ref
          .read(appUserNotifierProvider.notifier)
          .addExperience(widget.challenge.experienceToEarn);
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

  void _handleChallengeSuccess(BuildContext context) {
    if (widget.challenge.outroAnimation != null) {
      _initializeVideoController(widget.challenge.outroAnimation!);
      return;
    }

    widget.onChallengeCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final codeExecutionState = ref.watch(codeExecutionProvider);
    String output = codeExecutionState.output;
    bool isLoading = codeExecutionState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Coding Challenge',
          style: TextStyle(
              color: ThemeUtils.getTextColorForBackground(
                  Theme.of(context).primaryColor)),
        ),
      ),
      body: DraggableSplitScreen(
        leftWidget: _buildLeftPanel(output),
        rightWidget: _buildRightPanel(isLoading),
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

  Widget _buildRightPanel(bool isLoading) {
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
          child: _buildActionButtons(isLoading),
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
            if (widget.challenge.introAnimation != null) ...[
              ElevatedButton(
                onPressed: () {
                  _showVideoDialog();
                },
                child: const Text('Replay animation'),
              ),
            ]
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

  Widget _buildActionButtons(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: isLoading ? null : _runCode,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Run Code'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isLoading ? null : _submitCode,
            child: isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Submit Code'),
          ),
        ],
      ),
    );
  }

  String generateSampleCode(String language, Challenge challenge) {
    String className = challenge.className;
    String methodName = challenge.methodName;
    String returnType = _returnType;

    String javaArgs = '';
    String pythonArgs = '';

    if (challenge.unitTests.isNotEmpty &&
        challenge.unitTests.first.input.isNotEmpty) {
      javaArgs = challenge.unitTests.first.input.first.type.isEmpty
          ? ''
          : challenge.unitTests.first.input
              .map((e) =>
                  '${e.type} arg${challenge.unitTests.first.input.indexOf(e)}')
              .join(', ');

      pythonArgs = challenge.unitTests.first.input.first.type.isEmpty
          ? ''
          : challenge.unitTests.first.input
              .map((e) => 'arg${challenge.unitTests.first.input.indexOf(e)}')
              .join(', ');
    }

    if (language == 'java') {
      return """
  class $className {
    public $returnType $methodName($javaArgs) {
      // Your code here
    }
  }
  """;
    } else if (language == 'python') {
      return """
  class $className:
    def $methodName($pythonArgs):
      # Your code here
      pass
  """;
    }
    return '';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
