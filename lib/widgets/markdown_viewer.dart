import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/parsers/markdown_parser.dart';
import 'package:codecraft/providers/level_provider.dart';
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
      {Key? key, required this.markdownData, required this.quizName})
      : super(key: key);

  @override
  MarkdownViewerState createState() => MarkdownViewerState();
}

class MarkdownViewerState extends State<MarkdownViewer> {
  late PageController _pageController;
  late List<String> sections;

  @override
  void initState() {
    super.initState();
    _pageController = PageController()
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.markdownData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white,
              size: 200,
            ),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        // Split the Markdown content into sections using <br>
        sections = (snapshot.data as String).split('<br>');

        return Column(
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4.0, vertical: 2.0),
                  child: AnimatedProgressBar(
                    width: MediaQuery.of(context).size.width,
                    value: _pageController.hasClients
                        ? _pageController.page! / (sections.length - 1)
                        : 0.0,
                    duration: const Duration(seconds: 1),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.lightBlue,
                        Colors.lightBlue,
                        Colors.lightBlueAccent,
                        Colors.lightGreen,
                        Colors.lightGreen,
                        Colors.lightGreenAccent,
                      ],
                    ),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    curve: Curves.easeOutCubic,
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: sections.length,
                itemBuilder: (context, index) {
                  return Scrollbar(
                    thickness: 6,
                    controller: FixedExtentScrollController(),
                    child: Column(
                      children: [
                        Expanded(
                          child: MarkdownParser.parse(
                              data: sections[index], context: context),
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
                                    Dialogs.materialDialog(
                                        color: Colors.white,
                                        msg:
                                            'Congratulations, you passed the quiz!',
                                        title: 'Congratulations 🎉',
                                        lottieBuilder: Lottie.asset(
                                          'assets/anim/congrats.json',
                                          fit: BoxFit.contain,
                                        ),
                                        context: context,
                                        actions: [
                                          Builder(
                                            builder: (dialogContext) =>
                                                IconsButton(
                                              onPressed: () {
                                                Navigator.pop(dialogContext);
                                              },
                                              text: 'Okay!',
                                              iconData: Icons.done,
                                              color: Colors.blue,
                                              textStyle: const TextStyle(
                                                  color: Colors.white),
                                              iconColor: Colors.white,
                                            ),
                                          ),
                                        ]);

                                    Quiz quiz = result['quiz'] as Quiz;
                                    if (quiz.level >=
                                        Provider.of<LevelProvider>(context,
                                                listen: false)
                                            .currentLevel) {
                                      Provider.of<LevelProvider>(context,
                                              listen: false)
                                          .completeLevel();

                                      Dialogs.materialDialog(
                                          color: Colors.white,
                                          msg:
                                              'Congratulations, you have completed the level!',
                                          title: 'Congratulations 🎉',
                                          lottieBuilder: Lottie.asset(
                                            'assets/anim/level_up.json',
                                            fit: BoxFit.contain,
                                          ),
                                          context: context,
                                          actions: [
                                            Builder(
                                              builder: (dialogContext) =>
                                                  IconsButton(
                                                onPressed: () {
                                                  Navigator.pop(dialogContext);
                                                },
                                                text: 'Okay!',
                                                iconData: Icons.done,
                                                color: Colors.blue,
                                                textStyle: const TextStyle(
                                                    color: Colors.white),
                                                iconColor: Colors.white,
                                              ),
                                            ),
                                          ]);
                                    }
                                  } else {
                                    Dialogs.materialDialog(
                                      color: Colors.white,
                                      msg:
                                          'You did not pass the quiz... There is still room for improvement!',
                                      title: 'Try Again!',
                                      lottieBuilder: Lottie.asset(
                                        'assets/anim/failed.json',
                                        fit: BoxFit.contain,
                                      ),
                                      context: context,
                                      actions: [
                                        Builder(
                                          builder: (dialogContext) =>
                                              IconsButton(
                                            onPressed: () {
                                              Navigator.pop(dialogContext);
                                            },
                                            text: 'Okay!',
                                            iconData: Icons.done,
                                            color: Colors.blue,
                                            textStyle: const TextStyle(
                                                color: Colors.white),
                                            iconColor: Colors.white,
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              );
                            },
                            child: const Text('Test Your Knowledge!'),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
