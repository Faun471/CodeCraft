import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/parsers/markdown_parser.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:flutter_highlight/theme_map.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

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
  late PageController _pageController;
  late List<String> sections;
  late bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()..addListener(_onPageChanged);

    sections = [];

    widget.markdownData.split('<next page>').forEach((element) {
      sections.add(element);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    setState(() {});
  }

  double getPageValue() {
    return _pageController.hasClients
        ? _pageController.page! / (sections.length - 1)
        : 0.0;
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

  final tocController = TocController();

  final List<WidgetConfig> configs = [
    CodeConfig(
      style: const TextStyle(fontSize: 14, color: Colors.white),
    ),
    PreConfig(
      decoration: BoxDecoration(
        color: themeMap['atom-one-dark-reasonable']!['root']!.backgroundColor ??
            Colors.grey[800]!,
        borderRadius: BorderRadius.circular(8),
      ),
      theme: themeMap['atom-one-dark-reasonable']!,
      textStyle: const TextStyle(fontSize: 14),
      wrapper: (child, code, language) => CodeWrapperWidget(
        child,
        code,
        language,
      ),
    )
  ];

  late MarkdownConfig config;
  late bool isVertical;

  Widget buildTocWidget() => TocWidget(controller: tocController);

  Widget buildMarkdown(String data, MarkdownConfig config) => MarkdownWidget(
        data: data,
        tocController: tocController,
        config: config.copy(
          configs: configs,
        ),
      );

  Widget buildPageView(MarkdownConfig config) {
    return PageView.builder(
      controller: _pageController,
      itemCount: sections.length,
      itemBuilder: (context, index) {
        return Row(
          children: [
            if (!isVertical) Expanded(child: buildTocWidget()),
            Expanded(
              flex: 3,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: buildMarkdown(sections[index], config)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    isVertical = MediaQuery.of(context).size.aspectRatio < 1;
    config = Theme.of(context).brightness == Brightness.dark
        ? MarkdownConfig.darkConfig
        : MarkdownConfig.defaultConfig;
    return Scaffold(
      appBar: AppBar(
          // leading: IconButton(
          //   icon: const Icon(Icons.arrow_back),
          //   onPressed: () => Navigator.pop(context),
          // ),
          ),
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
      body: Column(
        children: [
          Stack(
            children: [
              AnimatedProgressBar(
                width: MediaQuery.of(context).size.width,
                value: _pageController.hasClients
                    ? _pageController.page! / (sections.length - 1)
                    : 0.0,
                duration: const Duration(seconds: 1),
                gradient: LinearGradient(
                  tileMode: TileMode.clamp,
                  colors: [
                    HSLColor.fromColor(
                            AdaptiveTheme.of(context).theme.colorScheme.primary)
                        .withSaturation(0.9)
                        .withHue(20)
                        .withLightness(
                            AdaptiveTheme.of(context).theme.brightness ==
                                    Brightness.dark
                                ? 0.5
                                : 0.8)
                        .toColor(),
                    HSLColor.fromColor(AdaptiveTheme.of(context)
                            .theme
                            .colorScheme
                            .secondaryContainer)
                        .withHue(80)
                        .withLightness(
                            AdaptiveTheme.of(context).theme.brightness ==
                                    Brightness.dark
                                ? 0.5
                                : 0.8)
                        .toColor(),
                  ],
                ),
                backgroundColor: Colors.grey.withOpacity(0.2),
                curve: Curves.easeOutCubic,
              ),
            ],
          ),
          Expanded(
            child: buildPageView(config),
          ),
        ],
      ),
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
}
