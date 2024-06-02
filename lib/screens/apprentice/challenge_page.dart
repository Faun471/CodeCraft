import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/providers/code_execution_provider.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/submission_service.dart';
import 'package:codecraft/widgets/codeblocks/code_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/java.dart';

class ChallengePage extends StatefulWidget {
  final Challenge challenge;

  ChallengePage({required this.challenge});

  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  final CodeLineEditingController _codeController = CodeLineEditingController();
  String _instructions = '';
  String _output = '';

  @override
  void initState() {
    super.initState();

    _instructions = widget.challenge.instructions;
    _codeController.text = widget.challenge.sampleCode;
  }

  void _submitCode() async {
    final script = _codeController.text;
    final codeExecutionProvider =
        Provider.of<CodeExecutionProvider>(context, listen: false);

    if (await codeExecutionProvider.allTestsPassed(
      script,
      widget.challenge.unitTests,
      widget.challenge.className,
    )) {
      await ChallengeService().markChallengeAsCompleted(
        AppUser.instance.userId,
        widget.challenge.id,
      );

      await SubmissionService()
          .submitCode(AppUser.instance.userId, widget.challenge.id, script);
    }

    setState(() {
      _output = codeExecutionProvider.output;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coding Challenge'),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Text(_instructions),
                    ),
                  ),
                ),
                Divider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Text(_output),
                    ),
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CodeEditorWidget(
                      selectedLanguage: langJava,
                      controller: _codeController,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitCode,
                  child: Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
