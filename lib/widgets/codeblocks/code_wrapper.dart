import 'package:codecraft/themes/theme.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:highlight/highlight.dart' show highlight, Node;

class CodeWrapperWidget extends StatefulWidget {
  final String text;
  final String language;
  final SyntaxTheme theme;
  final bool? isCopiable;
  final void Function(int)? onLineClicked;
  final void Function(int, String)? onLineEdited;
  final int? editingLine;

  const CodeWrapperWidget(
    this.text,
    this.language, {
    super.key,
    required this.theme,
    this.isCopiable,
    this.editingLine,
    this.onLineClicked,
    this.onLineEdited,
  });

  @override
  State<CodeWrapperWidget> createState() => _CodeWrapperState();
}

class _CodeWrapperState extends State<CodeWrapperWidget> {
  late List<String> lines;
  late Widget _switchWidget;
  bool hasCopied = false;
  late TextEditingController editingController;

  @override
  void initState() {
    super.initState();
    lines = widget.text.split('\n');
    editingController = TextEditingController();
    _switchWidget = Icon(
      Icons.copy_rounded,
      key: UniqueKey(),
      color: widget.theme.isLight ? Colors.black : Colors.white,
    );
  }

  @override
  void didUpdateWidget(CodeWrapperWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      lines = widget.text.split('\n');
    }
  }

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lineCount = lines.length;

    final textPainter = TextPainter(
      text: TextSpan(
        text: lineCount.toString(),
        style: GoogleFonts.firaCode(
          fontSize: 14,
          color: ThemeUtils.getTextColorForBackground(
            widget.theme.root.backgroundColor!,
          ),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final maxLineNumberWidth = textPainter.width + 8;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.theme.root.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lines.asMap().entries.map((entry) {
              int idx = entry.key;
              String line = entry.value;
              if (widget.editingLine != null && widget.editingLine == idx + 1) {
                editingController.text = line;
                editingController.selection = TextSelection.fromPosition(
                  TextPosition(offset: editingController.text.length),
                );
                return SizedBox(
                  height: 24,
                  child: TextField(
                    controller: editingController,
                    style: GoogleFonts.firaCode(
                      fontSize: 14,
                      color: widget.theme.isLight ? Colors.black : Colors.white,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (value) {
                      setState(() {
                        lines[idx] = value;
                      });
                      widget.onLineEdited?.call(idx + 1, value);
                    },
                  ),
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: maxLineNumberWidth,
                    child: Text(
                      '${idx + 1}',
                      style: GoogleFonts.firaCode(
                        fontSize: 14,
                        color: ThemeUtils.getTextColorForBackground(
                          widget.theme.root.backgroundColor!,
                        ),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => widget.onLineClicked?.call(idx + 1),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 1.5),
                        child: HighlightView(
                          line,
                          language: widget.language,
                          theme: draculaTheme,
                          padding: EdgeInsets.zero,
                          textStyle: GoogleFonts.firaCode(
                            fontSize: 14,
                            color: widget.theme.isLight
                                ? Colors.white
                                : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        if (widget.isCopiable != false)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.language.isNotEmpty)
                    SelectionContainer.disabled(
                      child: Container(
                        margin: const EdgeInsets.only(right: 2),
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: widget.theme.root.backgroundColor,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            width: 0.5,
                            color: widget.theme.isLight
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                        child: Text(
                          widget.language,
                          style: TextStyle(
                            color: widget.theme.isLight
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  InkWell(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _switchWidget,
                    ),
                    onTap: () async {
                      if (hasCopied) return;
                      await Clipboard.setData(
                          ClipboardData(text: lines.join('\n')));
                      _switchWidget = Icon(
                        Icons.check,
                        key: UniqueKey(),
                        color:
                            widget.theme.isLight ? Colors.black : Colors.white,
                      );
                      refresh();
                      Future.delayed(const Duration(seconds: 2), () {
                        hasCopied = false;
                        _switchWidget = Icon(
                          Icons.copy_rounded,
                          key: UniqueKey(),
                          color: widget.theme.isLight
                              ? Colors.black
                              : Colors.white,
                        );
                        refresh();
                      });
                    },
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}

class HighlightView extends StatelessWidget {
  final String source;
  final String? language;
  final Map<String, TextStyle> theme;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  HighlightView(
    String input, {
    super.key,
    this.language,
    this.theme = const {},
    this.padding,
    this.textStyle,
    int tabSize = 8,
  }) : source = input.replaceAll('\t', ' ' * tabSize);

  List<TextSpan> _convert(List<Node> nodes) {
    List<TextSpan> spans = [];
    var currentSpans = spans;
    List<List<TextSpan>> stack = [];

    traverse(Node node) {
      if (node.value != null) {
        currentSpans.add(node.className == null
            ? TextSpan(text: node.value)
            : TextSpan(text: node.value, style: theme[node.className!]));
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        currentSpans
            .add(TextSpan(children: tmp, style: theme[node.className!]));
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

  static const _rootKey = 'root';
  static const _defaultFontColor = Color(0xff000000);
  static const _defaultBackgroundColor = Color(0xffffffff);
  static const _defaultFontFamily = 'monospace';

  @override
  Widget build(BuildContext context) {
    var textStyle = TextStyle(
      fontFamily: _defaultFontFamily,
      color: theme[_rootKey]?.color ?? _defaultFontColor,
    );

    textStyle = textStyle.merge(this.textStyle);

    return Container(
      color: theme[_rootKey]?.backgroundColor ?? _defaultBackgroundColor,
      padding: padding,
      child: RichText(
        text: TextSpan(
          style: textStyle,
          children:
              _convert(highlight.parse(source, language: language).nodes!),
        ),
        softWrap: true,
        overflow: TextOverflow.clip,
      ),
    );
  }
}
