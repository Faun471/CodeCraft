import 'package:codecraft/models/challenge.dart';
import 'package:html/dom.dart' as h;
import 'package:html/parser.dart';
import 'package:html/dom_parsing.dart';
import 'package:codecraft/screens/apprentice/challenge_screen.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/themes/theme.dart';
import 'package:codecraft/widgets/codeblocks/code_wrapper.dart';
import 'package:highlight/highlight.dart' show Node, highlight;
import 'package:markdown_widget/markdown_widget.dart';
import 'package:markdown/markdown.dart' as m;
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
      drawer: isVertical
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
          if (!isVertical) Expanded(child: buildTocWidget()),
          if (!isVertical)
            Expanded(
              child: buildMarkdown(markdownData, config),
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
  final String? challengeId;

  const ChallengeButton({super.key, this.challengeId});

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
                ChallengeService().getChallenge(widget.challengeId!),
              ],
              onDone: (context, p1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChallengeScreen(
                      challenge: p1.data[0] as Challenge,
                    ),
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

class CustomTextNode extends ElementNode {
  final String text;
  final MarkdownConfig config;
  final WidgetVisitor visitor;

  CustomTextNode(this.text, this.config, this.visitor);

  @override
  void onAccepted(SpanNode parent) {
    final textStyle = config.p.textStyle.merge(parentStyle);
    children.clear();
    if (!text.contains(htmlRep)) {
      accept(TextNode(text: text, style: textStyle));
      return;
    }
    final spans = parseHtml(
      m.Text(text),
      visitor: WidgetVisitor(
        config: visitor.config,
        generators: visitor.generators,
        richTextBuilder: visitor.richTextBuilder,
      ),
      parentStyle: parentStyle,
    );
    for (var element in spans) {
      accept(element);
    }
  }
}

void htmlToMarkdown(h.Node? node, int deep, List<m.Node> mNodes) {
  if (node == null) return;
  if (node is h.Text) {
    mNodes.add(m.Text(node.text));
  } else if (node is h.Element) {
    final tag = node.localName;
    List<m.Node> children = [];
    for (var e in node.children) {
      htmlToMarkdown(e, deep + 1, children);
    }
    m.Element element;
    if (tag == MarkdownTag.img.name || tag == 'video') {
      element = HtmlElement(tag!, children, node.text);
      element.attributes.addAll(node.attributes.cast());
    } else {
      element = HtmlElement(tag!, children, node.text);
      element.attributes.addAll(node.attributes.cast());
    }
    mNodes.add(element);
  }
}

final RegExp htmlRep = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: true);

///parse [m.Node] to [h.Node]
List<SpanNode> parseHtml(
  m.Text node, {
  ValueCallback<dynamic>? onError,
  WidgetVisitor? visitor,
  TextStyle? parentStyle,
}) {
  try {
    final text = node.textContent.replaceAll(
        visitor?.splitRegExp ?? WidgetVisitor.defaultSplitRegExp, '');
    if (!text.contains(htmlRep)) return [TextNode(text: node.text)];
    h.DocumentFragment document = parseFragment(text);
    return HtmlToSpanVisitor(visitor: visitor, parentStyle: parentStyle)
        .toVisit(document.nodes.toList());
  } catch (e) {
    onError?.call(e);
    return [TextNode(text: node.text)];
  }
}

class HtmlElement extends m.Element {
  @override
  final String textContent;

  HtmlElement(super.tag, super.children, this.textContent);
}

class HtmlToSpanVisitor extends TreeVisitor {
  final List<SpanNode> _spans = [];
  final List<SpanNode> _spansStack = [];
  final WidgetVisitor visitor;
  final TextStyle parentStyle;

  HtmlToSpanVisitor({WidgetVisitor? visitor, TextStyle? parentStyle})
      : visitor = visitor ?? WidgetVisitor(),
        parentStyle = parentStyle ?? const TextStyle();

  List<SpanNode> toVisit(List<h.Node> nodes) {
    _spans.clear();
    for (final node in nodes) {
      final emptyNode = ConcreteElementNode(style: parentStyle);
      _spans.add(emptyNode);
      _spansStack.add(emptyNode);
      visit(node);
      _spansStack.removeLast();
    }
    final result = List.of(_spans);
    _spans.clear();
    _spansStack.clear();
    return result;
  }

  @override
  void visitText(h.Text node) {
    final last = _spansStack.last;
    if (last is ElementNode) {
      final textNode = TextNode(text: node.text);
      last.accept(textNode);
    }
  }

  @override
  void visitElement(h.Element node) {
    final localName = node.localName ?? '';
    final mdElement = m.Element(localName, []);
    mdElement.attributes.addAll(node.attributes.cast());
    SpanNode spanNode = visitor.getNodeByElement(mdElement, visitor.config);
    if (spanNode is! ElementNode) {
      final n = ConcreteElementNode(tag: localName, style: parentStyle);
      n.accept(spanNode);
      spanNode = n;
    }
    final last = _spansStack.last;
    if (last is ElementNode) {
      last.accept(spanNode);
    }
    _spansStack.add(spanNode);
    for (var child in node.nodes.toList(growable: false)) {
      visit(child);
    }
    _spansStack.removeLast();
  }
}
