import 'dart:math';

import 'package:codecraft/widgets/codeblocks/auto_scroll_list_view.dart';
import 'package:codecraft/widgets/codeblocks/find_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/dracula.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/dart.dart';
import 'package:re_highlight/languages/java.dart';
import 'package:re_highlight/re_highlight.dart';

class CodeEditorWidget extends StatefulWidget {
  final Mode? selectedLanguage;
  final CodeLineEditingController controller;

  const CodeEditorWidget(
      {super.key, this.selectedLanguage, required this.controller});

  @override
  _CodeEditorWidgetState createState() => _CodeEditorWidgetState();
}

class _CodeEditorWidgetState extends State<CodeEditorWidget> {
  @override
  Widget build(BuildContext context) {
    return CodeAutocomplete(
      viewBuilder: (context, notifier, onSelected) =>
          _DefaultCodeAutocompleteListView(
        notifier: notifier,
        onSelected: onSelected,
      ),
      promptsBuilder: DefaultCodeAutocompletePromptsBuilder(
        language: widget.selectedLanguage ?? langDart,
        directPrompts: [
          const CodeKeywordPrompt(word: 'String'),
          const CodeFunctionPrompt(word: 'System.out.println', type: 'void'),
          const CodeFunctionPrompt(word: 'main', type: 'void'),
        ],
      ),
      child: CodeEditor(
        controller: widget.controller,
        chunkAnalyzer: const DefaultCodeChunkAnalyzer(),
        indicatorBuilder:
            (context, editingController, chunkController, notifier) {
          return Row(
            children: [
              DefaultCodeLineNumber(
                controller: editingController,
                notifier: notifier,
              ),
              DefaultCodeChunkIndicator(
                  width: 20, controller: chunkController, notifier: notifier)
            ],
          );
        },
        findBuilder: (context, controller, readOnly) =>
            CodeFindPanelView(controller: controller, readOnly: readOnly),
        style: CodeEditorStyle(
          backgroundColor: const Color.fromARGB(255, 30, 30, 30),
          fontFamily: GoogleFonts.firaCode().fontFamily,
          textColor: Colors.white,
          fontSize: 14.0,
          codeTheme: CodeHighlightTheme(
            languages: {
              'java': CodeHighlightThemeMode(mode: langJava),
              'dart': CodeHighlightThemeMode(mode: langDart),
            },
            theme: draculaTheme,
          ),
        ),
      ),
    );
  }
}

class _DefaultCodeAutocompleteListView extends StatefulWidget
    implements PreferredSizeWidget {
  static const double kItemHeight = 26;

  final ValueNotifier<CodeAutocompleteEditingValue> notifier;
  final ValueChanged<CodeAutocompleteResult> onSelected;

  const _DefaultCodeAutocompleteListView({
    required this.notifier,
    required this.onSelected,
  });

  @override
  Size get preferredSize => Size(
      250,
      // 2 is border size
      min(kItemHeight * notifier.value.prompts.length, 150) + 2);

  @override
  State<StatefulWidget> createState() =>
      _DefaultCodeAutocompleteListViewState();
}

class _DefaultCodeAutocompleteListViewState
    extends State<_DefaultCodeAutocompleteListView> {
  @override
  void initState() {
    widget.notifier.addListener(_onValueChanged);
    super.initState();
  }

  @override
  void dispose() {
    widget.notifier.removeListener(_onValueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints.loose(widget.preferredSize),
        decoration: BoxDecoration(
            color: Colors.grey, borderRadius: BorderRadius.circular(6)),
        child: AutoScrollListView(
          controller: ScrollController(),
          initialIndex: widget.notifier.value.index,
          scrollDirection: Axis.vertical,
          itemCount: widget.notifier.value.prompts.length,
          itemBuilder: (context, index) {
            final CodePrompt prompt = widget.notifier.value.prompts[index];
            final BorderRadius radius = BorderRadius.only(
              topLeft: index == 0 ? const Radius.circular(5) : Radius.zero,
              topRight: index == 0 ? const Radius.circular(5) : Radius.zero,
              bottomLeft: index == widget.notifier.value.prompts.length - 1
                  ? const Radius.circular(5)
                  : Radius.zero,
              bottomRight: index == widget.notifier.value.prompts.length - 1
                  ? const Radius.circular(5)
                  : Radius.zero,
            );
            return InkWell(
                borderRadius: radius,
                onTap: () {
                  widget.onSelected(widget.notifier.value
                      .copyWith(index: index)
                      .autocomplete);
                },
                child: Container(
                  width: double.infinity,
                  height: _DefaultCodeAutocompleteListView.kItemHeight,
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                      color: index == widget.notifier.value.index
                          ? const Color.fromARGB(255, 60, 60, 60)
                          : null,
                      borderRadius: radius),
                  child: RichText(
                    text:
                        prompt.createSpan(context, widget.notifier.value.input),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ));
          },
        ));
  }

  void _onValueChanged() {
    setState(() {});
  }
}

extension _CodePromptExtension on CodePrompt {
  InlineSpan createSpan(BuildContext context, String input) {
    const TextStyle style = TextStyle(color: Colors.white);
    final InlineSpan span = style.createSpan(
      value: word,
      anchor: input,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    );
    final CodePrompt prompt = this;
    if (prompt is CodeFieldPrompt) {
      return TextSpan(children: [
        span,
        TextSpan(
            text: ' ${prompt.type}',
            style: style.copyWith(color: Colors.lightGreen))
      ]);
    }
    if (prompt is CodeFunctionPrompt) {
      return TextSpan(children: [
        span,
        TextSpan(
            text: ' (...) -> ${prompt.type}',
            style: style.copyWith(color: Colors.lightGreen))
      ]);
    }
    return span;
  }
}

extension _TextStyleExtension on TextStyle {
  InlineSpan createSpan({
    required String value,
    required String anchor,
    required Color color,
    FontWeight? fontWeight,
    bool casesensitive = false,
  }) {
    if (anchor.isEmpty) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    final int index;
    if (casesensitive) {
      index = value.indexOf(anchor);
    } else {
      index = value.toLowerCase().indexOf(anchor.toLowerCase());
    }
    if (index < 0) {
      return TextSpan(
        text: value,
        style: this,
      );
    }
    return TextSpan(children: [
      TextSpan(text: value.substring(0, index), style: this),
      TextSpan(
          text: value.substring(index, index + anchor.length),
          style: copyWith(
            color: color,
            fontWeight: fontWeight,
          )),
      TextSpan(text: value.substring(index + anchor.length), style: this)
    ]);
  }
}
