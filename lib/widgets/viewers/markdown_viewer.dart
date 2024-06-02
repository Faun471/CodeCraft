import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/challenge.dart';

import 'package:codecraft/screens/apprentice/challenge_page.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:codecraft/widgets/codeblocks/code_wrapper.dart';
import 'package:codecraft/widgets/screentypes/split_screen.dart';
import 'package:highlight/highlight.dart' show Node, highlight;
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/material.dart';

class MarkdownViewer extends StatefulWidget {
  final String markdownData;
  final String quizName;

  const MarkdownViewer({
    super.key,
    required this.markdownData,
    required this.quizName,
  });

  @override
  MarkdownViewerState createState() => MarkdownViewerState();
}

class MarkdownViewerState extends State<MarkdownViewer> {
  late bool isEditMode = false;

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
          RichText(
            text: _SyntaxHighlighter(
              theme: SyntaxTheme.dracula,
              language: language,
            ).format(code),
          ),
          code,
          language,
          theme: SyntaxTheme.dracula,
        );
      },
    )
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
              PConfig(textStyle: TextStyle(fontSize: 16, color: Colors.black)),
            ],
          );
    return Scaffold(
      appBar: AppBar(
        actions: [
          if (AppUser.instance.data['accountType'] == 'teacher' && isEditMode)
            IconButton(
              icon: Icon(Icons.save_rounded),
              onPressed: () {},
            ),
        ],
      ),
      floatingActionButton: AppUser.instance.data['accountType'] == 'teacher'
          ? buildFloatingActionButton()
          : null,
      drawer: isVertical && !isEditMode
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
          if (!isVertical && !isEditMode) Expanded(child: buildTocWidget()),
          if (!isVertical && isEditMode)
            Expanded(
              child: DraggableSplitScreen(
                leftWidget: buildEditText(),
                rightWidget: buildMarkdown(markdownData, config),
              ),
            ),
          if (!isEditMode)
            Expanded(flex: 3, child: buildMarkdown(markdownData, config))
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
            padding: EdgeInsets.all(24),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
          width: MediaQuery.of(context).size.width * 0.5,
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChallengePage(
                      challenge: Challenge(
                          id: 'lesson1_challenge1',
                          instructions:
                              'Write a function that returns "Hello, World!" as a string.',
                          sampleCode:
                              'class HelloWorld {\n\tpublic String helloWorld() {\n \t\t// Write your code here\n\t}\n}',
                          className: 'HelloWorld',
                          unitTests: [
                            UnitTest(
                              input: '',
                              expectedOutput: ExpectedOutput(
                                value: 'Hello, World!',
                                type: 'String',
                              ),
                              methodName: 'helloWorld',
                            )
                          ]),
                    ),
                  ),
                );
              },
              child: Text('Proceed to challenge')),
        )
      ],
    );
  }

  Widget buildFloatingActionButton() {
    return FloatingActionButton(
      isExtended: true,
      onPressed: () {
        setState(() {
          isEditMode = !isEditMode;
        });
      },
      child: Icon(
        isEditMode ? Icons.edit_off : Icons.edit,
        color: Colors.white,
      ),
    );
  }

  Widget buildEditText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MarkdownTextInput(
          () {},
          controller.text,
          controller: controller,
          maxLines: 25,
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

class _SyntaxHighlighter {
  final SyntaxTheme theme;
  final String? language;

  _SyntaxHighlighter({required this.theme, required this.language});

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

    _traverse(Node node) {
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

        node.children!.forEach((n) {
          _traverse(n);
          if (n == node.children!.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        });
      }
    }

    for (var node in nodes) {
      _traverse(node);
    }

    return spans;
  }
}
