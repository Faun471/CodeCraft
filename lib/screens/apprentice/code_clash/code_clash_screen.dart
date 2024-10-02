import 'dart:async';

import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/providers/code_clash_provider.dart';
import 'package:codecraft/screens/apprentice/code_clash/code_clash_results_screen.dart';
import 'package:codecraft/services/code_clash_service.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:codecraft/widgets/codeblocks/code_wrapper.dart';
import 'package:codecraft/widgets/screentypes/split_screen.dart';
import 'package:codecraft/widgets/viewers/markdown_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/languages/python.dart';

class CodeClashScreen extends ConsumerStatefulWidget {
  final CodeClash codeClash;

  const CodeClashScreen({super.key, required this.codeClash});

  @override
  _CodeClashScreenState createState() => _CodeClashScreenState();
}

class _CodeClashScreenState extends ConsumerState<CodeClashScreen> {
  final CodeLineEditingController _codeController = CodeLineEditingController();
  final String _selectedLanguage = 'java';
  late Timer _timer;
  int _remainingTime = 0;

  @override
  void initState() {
    super.initState();
    _initializeCodeClash();
    _startTimer();
  }

  void _initializeCodeClash() {
    _codeController.text = widget.codeClash.sampleCode!;
    final appUserState = ref.read(appUserNotifierProvider);
    ref
        .read(codeClashProvider.notifier)
        .startListening(widget.codeClash.id, appUserState.value!.orgId!);
  }

  void _startTimer() {
    if (widget.codeClash.startTime == null) return;

    final DateTime startTime = widget.codeClash.startTime!.toDate();
    final int timeElapsed = DateTime.now().difference(startTime).inSeconds;
    final int totalTimeInSeconds = widget.codeClash.timeLimit * 60;

    _remainingTime = totalTimeInSeconds - timeElapsed;

    if (_remainingTime <= 0) {
      _endCodeClash();
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime > 0) {
            _remainingTime--;
          } else {
            _timer.cancel();
            _endCodeClash();
          }
        });
      });
    }
  }

  void _runCode() {
    final codeClashNotifier = ref.read(codeClashProvider.notifier);
    codeClashNotifier.executeCode(
      _codeController.text,
      widget.codeClash.unitTests,
      widget.codeClash.className,
      _selectedLanguage,
      widget.codeClash.methodName,
    );
  }

  void _submitCode() async {
    final codeClashNotifier = ref.read(codeClashProvider.notifier);
    final appUserState = ref.read(appUserNotifierProvider);

    if (await codeClashNotifier.isCorrectSolution(
      _codeController.text,
      widget.codeClash.unitTests,
      widget.codeClash.className,
      _selectedLanguage,
      widget.codeClash.methodName,
    )) {
      await CodeClashService().submitSolution(
          appUserState.value!.orgId!,
          widget.codeClash.id,
          FirebaseAuth.instance.currentUser!.uid,
          _codeController.text);

      if (!mounted) return;
      Utils.displayDialog(
        context: context,
        title: 'Solution Submitted!',
        content: 'Your solution has been submitted successfully.',
        lottieAsset: 'assets/anim/congrats.json',
        onDismiss: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LeaderboardScreen(
                codeClashId: widget.codeClash.id,
                organizationId: appUserState.value!.orgId!,
              ),
            ),
          );
        },
      );
    } else {
      if (!mounted) return;
      Utils.displayDialog(
        context: context,
        title: 'Incorrect Solution',
        content:
            'Your solution did not produce the expected output. Try again!',
        lottieAsset: 'assets/anim/failed.json',
      );
    }
  }

  void _endCodeClash() async {
    final appUserState = ref.read(appUserNotifierProvider);
    await CodeClashService()
        .endCodeClash(appUserState.value!.orgId!, widget.codeClash.id);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => LeaderboardScreen(
        codeClashId: widget.codeClash.id,
        organizationId: appUserState.value!.orgId!,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final codeClashState = ref.watch(codeClashProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Code Clash: ${widget.codeClash.title}',
          style: TextStyle(
              color: ThemeUtils.getTextColor(Theme.of(context).primaryColor)),
        ),
        actions: [
          Center(
            child: Text(
              'Time left: ${_formatTime(_remainingTime)}',
              // style: TextStyle(
              //   color: ThemeUtils.getTextColor(Theme.of(context).primaryColor),
              // ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: DraggableSplitScreen(
        leftWidget: _buildLeftPanel(
          codeClashState,
          ref.read(codeClashProvider.notifier),
        ),
        rightWidget: _buildRightPanel(),
      ),
    );
  }

  Widget _buildLeftPanel(
      CodeClashState codeClashState, CodeClashNotifier codeClashNotifier) {
    return DraggableSplitScreen(
      isVertical: true,
      leftWidget: _buildInstructionsCard(),
      rightWidget: _buildOutputCard(codeClashState, codeClashNotifier),
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
                markdownData: widget.codeClash.instructions,
                displayToc: false,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputCard(
      CodeClashState codeClashState, CodeClashNotifier codeClashNotifier) {
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
                    codeClashNotifier.resetOutput();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: CodeWrapperWidget(
                  codeClashState.output.isEmpty
                      ? 'No output'
                      : codeClashState.output,
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

  Widget _buildRightPanel() {
    return Column(
      children: [
        Expanded(child: _buildCodeEditorCard()), // For Code Editor
        _buildActionButtons(), // Action buttons at bottom-right
      ],
    );
  }

  Widget _buildCodeEditorCard() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: CodeEditorWidget(
        selectedLanguage: _selectedLanguage == 'java' ? langJava : langPython,
        controller: _codeController,
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
            child: Text(
              'Run Code',
              style: TextStyle(
                color: ThemeUtils.getTextColor(Theme.of(context).primaryColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _submitCode,
            child: Text(
              'Submit Solution',
              style: TextStyle(
                color: ThemeUtils.getTextColor(Theme.of(context).primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
