import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/parser/html_parser.dart';
import 'package:codecraft/screens/apprentice/coding_challenges/coding_challenge_screen.dart';
import 'package:codecraft/screens/apprentice/coding_quizzes/completed_quiz_screen.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:codecraft/widgets/codeblocks/code_wrapper.dart';
import 'package:codecraft/widgets/viewers/quiz_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/highlight.dart' show Node, highlight;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/material.dart';

class MarkdownViewer extends StatefulWidget {
  final String markdownData;
  final bool? displayToc;

  const MarkdownViewer({
    super.key,
    required this.markdownData,
    this.displayToc = true,
  });

  @override
  MarkdownViewerState createState() => MarkdownViewerState();
}

class MarkdownViewerState extends State<MarkdownViewer> {
  TextEditingController controller = TextEditingController();
  FocusNode focusNode = FocusNode();
  String get markdownData => controller.text;

  @override
  void initState() {
    super.initState();
    controller.text = widget.markdownData;
    controller.addListener(refresh);
  }

  @override
  void dispose() {
    super.dispose();
  }

  final tocController = TocController();

  final List<WidgetConfig> configs = [
    CodeConfig(
      style: TextStyle(
        fontSize: 14,
        color: SyntaxTheme.dracula.isLight ? Colors.black : Colors.white,
      ),
    ),
    PreConfig(
      builder: (code, language) {
        return CodeWrapperWidget(
          code,
          language,
          theme: SyntaxTheme.dracula,
        );
      },
    ),
  ];

  late MarkdownConfig config;
  late bool isVertical;

  @override
  Widget build(BuildContext context) {
    isVertical = MediaQuery.of(context).size.aspectRatio < 1;
    config = Theme.of(context).brightness == Brightness.dark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig.copy(
            configs: [
              const PConfig(
                  textStyle: TextStyle(fontSize: 16, color: Colors.black)),
            ],
          );
    return Scaffold(
      appBar: widget.displayToc == true ? AppBar() : null,
      drawer: isVertical && widget.displayToc == true
          ? Drawer(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'Table of Contents',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                const Divider(),
                Expanded(child: buildTocWidget())
              ],
            ))
          : null,
      body: Row(
        children: [
          if (!isVertical && widget.displayToc == true) ...[
            Expanded(
              flex: 1,
              child: buildTocWidget(),
            ),
            const VerticalDivider(),
          ],
          Expanded(
            flex: 3,
            child: buildMarkdown(
              markdownData,
              config,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTocWidget() {
    return TocWidget(controller: tocController);
  }

  Widget buildMarkdown(String data, MarkdownConfig config) {
    return Column(
      children: [
        Expanded(
          child: MarkdownWidget(
            data: data,
            tocController: tocController,
            config: config.copy(
              configs: configs,
            ),
            markdownGenerator: MarkdownGenerator(
              generators: [
                challengeGeneratorWithTag,
                quizGeneratorWithTag,
              ],
              textGenerator: (node, config, visitor) =>
                  CustomTextNode(node.textContent, config, visitor),
            ),
            padding: const EdgeInsets.all(24),
          ),
        ),
      ],
    );
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }
}

class SyntaxHighlighter {
  final SyntaxTheme theme;
  final String? language;

  SyntaxHighlighter({required this.theme, required this.language});

  TextSpan format(String source) {
    return TextSpan(
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 16.0,
        height: 1.5,
        color: theme.isLight ? Colors.black : Colors.white,
      ),
      children: [
        ..._convert(
          highlight
              .parse(
                source.trimRight(),
                language: language,
              )
              .nodes!,
        ),
      ],
    );
  }

  List<TextSpan> _convert(List<Node> nodes) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    List<List<TextSpan>> stack = [];

    traverse(Node node) {
      if (node.value != null) {
        currentSpans.add(node.className == null
            ? TextSpan(text: node.value)
            : TextSpan(text: node.value, style: theme.theme[node.className!]));
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans
            .add(TextSpan(children: tmp, style: theme.theme[node.className!]));
        stack.add(currentSpans);
        currentSpans = tmp;

        for (var n in node.children!) {
          traverse(n);
          if (n == node.children!.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        }
      }
    }

    for (var node in nodes) {
      traverse(node);
    }

    return spans;
  }
}

SpanNodeGeneratorWithTag challengeGeneratorWithTag = SpanNodeGeneratorWithTag(
    tag: _challengeTag,
    generator: (e, config, visitor) => ChallengeButtonNode(e.attributes));

const _challengeTag = 'challenge';

class ChallengeButtonNode extends ElementNode {
  final Map<String, String> attributes;

  ChallengeButtonNode(this.attributes);

  @override
  InlineSpan build() {
    String? challengeId;

    if (attributes.containsKey('challenge-id')) {
      challengeId = attributes['challenge-id'];
    }

    return WidgetSpan(child: ChallengeButton(challengeId: challengeId));
  }
}

class ChallengeButton extends StatefulWidget {
  final String? orgId;
  final String? challengeId;

  const ChallengeButton({super.key, this.challengeId, this.orgId});

  @override
  _ChallengeButtonState createState() => _ChallengeButtonState();
}

class _ChallengeButtonState extends State<ChallengeButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue),
        fixedSize: WidgetStateProperty.all(const Size(200, 50)),
      ),
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingScreen(
              futures: [
                ChallengeService().getChallenge('Default', widget.challengeId!),
                ChallengeService().getCompletedChallenges(
                  FirebaseAuth.instance.currentUser!.uid,
                )
              ],
              onDone: (context, snapshot) {
                if (snapshot.data[0] == null) {
                  return;
                }

                if (snapshot.error != null) {
                  return;
                }

                if (snapshot.data.isEmpty) {
                  return;
                }

                final challenge = snapshot.data[0] as Challenge;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChallengeScreen(challenge: challenge),
                  ),
                );
              },
            ),
          ),
        );
      },
      child: const Text('Proceed to challenge'),
    );
  }
}

SpanNodeGeneratorWithTag quizGeneratorWithTag = SpanNodeGeneratorWithTag(
    tag: _quizTag,
    generator: (e, config, visitor) => QuizButtonNode(e.attributes));

const _quizTag = 'quiz';

class QuizButtonNode extends ElementNode {
  final Map<String, String> attributes;

  QuizButtonNode(this.attributes);

  @override
  InlineSpan build() {
    String? quizId;

    if (attributes.containsKey('quiz-id')) {
      quizId = attributes['quiz-id'];
    }

    return WidgetSpan(child: QuizButton(quizId: quizId));
  }
}

class QuizButton extends ConsumerStatefulWidget {
  final String? orgId;
  final String? quizId;

  const QuizButton({super.key, this.quizId, this.orgId});

  @override
  _QuizButtonState createState() => _QuizButtonState();
}

class _QuizButtonState extends ConsumerState<QuizButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.blue),
        fixedSize: WidgetStateProperty.all(const Size(200, 50)),
      ),
      onPressed: () async {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingScreen(
              futures: [
                QuizService().getQuiz('Default', widget.quizId!),
                QuizService().getCompletedQuizzes(
                  FirebaseAuth.instance.currentUser!.uid,
                ),
                QuizService().getQuizResult(
                  widget.quizId!,
                ),
              ],
              onDone: (context, snapshot) {
                if (snapshot.data[0] == null) {
                  return;
                }

                if (snapshot.error != null) {
                  return;
                }

                final quiz = snapshot.data[0] as Quiz;

                final QuizResult? quizResult = snapshot.data[2] as QuizResult?;
                if (quizResult != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizResultsScreen(
                        quiz: quiz,
                        quizResult: quizResult,
                        showSolutions: false,
                        canRetake: true,
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizViewer(
                      quiz: quiz,
                      onQuizFinished: (quiz) {
                        QuizService().saveQuizResultsWithAnswers(quiz);

                        //if quiz is perfect, add experience
                        if (quiz.isPerfect) {
                          final appUserNotifier =
                              ref.watch(appUserNotifierProvider.notifier);
                          appUserNotifier.addExperience(
                            quiz.experienceToEarn,
                          );
                        }

                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
      child: const Text('Proceed to Quiz'),
    );
  }
}
