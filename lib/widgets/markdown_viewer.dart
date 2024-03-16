import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/parsers/markdown_parser.dart';
import 'package:codecraft/providers/level_provider.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/screens/quiz_screen.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

class MarkdownViewer extends StatefulWidget {
  final Future<String> markdownData;
  final String quizName;

  const MarkdownViewer(
      {super.key, required this.markdownData, required this.quizName});

  @override
  MarkdownViewerState createState() => MarkdownViewerState();
}

class MarkdownViewerState extends State<MarkdownViewer> {
  late PageController _pageController;
  late List<String> sections;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()..addListener(_onPageChanged);
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

  Widget buildLoadingWidget() {
    return Center(
      child: LoadingAnimationWidget.staggeredDotsWave(
        color: Colors.white,
        size: 200,
      ),
    );
  }

  Widget buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: sections.length,
      itemBuilder: (context, index) {
        return Scrollbar(
          thickness: 6,
          controller: FixedExtentScrollController(),
          child: Column(
            children: [
              Expanded(
                child: SelectionArea(
                  child: MarkdownParser.parse(
                      data: sections[index], context: context),
                ),
              ),
              if (index < sections.length - 1)
                ElevatedButton(
                  onPressed: () {
                    _pageController.nextPage(
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: const Text('Continue Reading'),
                ),
              if (index == sections.length - 1)
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            quizName: widget.quizName,
                          ),
                        )).then(
                      (value) {
                        if (value == null) {
                          return;
                        }

                        final Map<String, dynamic> result =
                            value as Map<String, dynamic>;

                        if (result['passed'] == true) {
                          showMaterialDialog(
                            context: context,
                            message: 'You passed the quiz! Congratulations!',
                            title: 'Congratulations!🎉',
                            lottieBuilder: Lottie.asset(
                              'assets/anim/congrats.json',
                              fit: BoxFit.contain,
                            ),
                          );

                          Quiz quiz = result['quiz'] as Quiz;
                          if (quiz.level >=
                              Provider.of<LevelProvider>(context, listen: false)
                                  .currentLevel) {
                            Provider.of<LevelProvider>(context, listen: false)
                                .completeLevel();

                            showMaterialDialog(
                              context: context,
                              message: 'You have unlocked a new level!',
                              title: 'New Level Unlocked!',
                              lottieBuilder: Lottie.asset(
                                'assets/anim/level_up.json',
                                fit: BoxFit.contain,
                              ),
                            );
                          }
                          return;
                        }
                        showMaterialDialog(
                          context: context,
                          message:
                              'You did not pass the quiz... There is still room for improvement!',
                          title: 'You can always try again!',
                          lottieBuilder: Lottie.asset(
                            'assets/anim/failed.json',
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Test Your Knowledge!'),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.markdownData,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return buildLoadingWidget();
        }

        sections = (snapshot.data as String).split('<next page>');

        return Column(
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
                      HSLColor.fromColor(AdaptiveTheme.of(context)
                              .theme
                              .colorScheme
                              .primary)
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
              child: buildPageView(),
            ),
          ],
        );
      },
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
