import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/parsers/markdown_parser.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/widgets/split_screen.dart';
import 'package:flutter_markdown/flutter_markdown.dart' as md;
import 'package:flutter_syntax_view/flutter_syntax_view.dart';
import 'package:markdown_editable_textinput/markdown_text_input.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:provider/provider.dart';

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
      style: const TextStyle(fontSize: 14, color: Colors.white),
    ),
    PreConfig(
      decoration: BoxDecoration(
        color: SyntaxTheme.dracula().backgroundColor!,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(fontSize: 14),
      builder: (code, language) {
        return CodeWrapperWidget(
          RichText(
            text: _SyntaxHighlighter(
              theme: SyntaxTheme.dracula(),
              language: Syntax.JAVA,
            ).format(code),
          ),
          code,
          language,
          theme: SyntaxTheme.dracula(),
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
    return MarkdownWidget(
      data: data,
      tocController: tocController,
      config: config.copy(
        configs: configs,
      ),
      padding: EdgeInsets.all(24),
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

  void showMaterialDialog({
    required BuildContext context,
    required String message,
    required String title,
    required LottieBuilder? lottieBuilder,
  }) {
    Dialogs.materialDialog(
      msg: message,
      dialogWidth: 0.25,
      msgStyle:
          AdaptiveTheme.of(context).theme.textTheme.displaySmall!.copyWith(
                color: Colors.black,
              ),
      msgAlign: TextAlign.center,
      titleStyle: TextStyle(
        color:
            Provider.of<ThemeProvider>(context, listen: false).preferredColor,
        fontSize: MediaQuery.of(context).size.width * 0.05,
        fontWeight: FontWeight.bold,
      ),
      titleAlign: TextAlign.center,
      title: title,
      lottieBuilder: lottieBuilder,
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      actions: [
        Builder(
          builder: (dialogContext) => IconsButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            text: 'Okay!',
            iconData: Icons.done,
            color: Provider.of<ThemeProvider>(context, listen: false)
                .preferredColor,
            textStyle: const TextStyle(color: Colors.white),
            iconColor: Colors.white,
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

class _SyntaxHighlighter extends md.SyntaxHighlighter {
  final SyntaxTheme theme;
  final Syntax language;

  _SyntaxHighlighter({required this.theme, required this.language});

  @override
  TextSpan format(String source) {
    return TextSpan(
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 16.0,
        height: 1.5,
        color: Colors.white,
      ),
      children: [
        JavaSyntaxHighlighter(SyntaxTheme.dracula()).format(source.trimRight()),
      ],
    );
  }

  SyntaxBase getSytaxBase(Syntax syntax) {
    switch (syntax) {
      case Syntax.JAVA:
        return JavaSyntaxHighlighter(SyntaxTheme.dracula());
      case Syntax.DART:
        return DartSyntaxHighlighter(SyntaxTheme.dracula());
      default:
        return YamlSyntaxHighlighter(SyntaxTheme.dracula());
    }
  }
}
