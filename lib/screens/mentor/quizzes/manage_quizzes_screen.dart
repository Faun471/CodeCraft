import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/screens/mentor/quizzes/create_quiz_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:universal_html/html.dart' as web;

class ManageQuizzesScreen extends ConsumerStatefulWidget {
  const ManageQuizzesScreen({super.key});

  @override
  _ManageChallengeScreenState createState() => _ManageChallengeScreenState();
}

class _ManageChallengeScreenState extends ConsumerState<ManageQuizzesScreen> {
  @override
  void initState() {
    super.initState();

    web.document.onContextMenu.listen((event) => event.preventDefault());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(appUserNotifierProvider).value;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Manage Quizzes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'This is where quizzes will be edited.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<Quiz>>(
            stream: QuizService().getQuizzesStream(user!.orgId!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return LoadingAnimationWidget.flickr(
                  leftDotColor: Theme.of(context).primaryColor,
                  rightDotColor: Theme.of(context).colorScheme.secondary,
                  size: MediaQuery.of(context).size.width * 0.1,
                );
              }

              if (snapshot.hasError) {
                return const Center(
                  child: Text('An error occurred, please try again later!'),
                );
              }

              if (snapshot.data!.isEmpty) {
                return const Column(
                  children: [
                    Center(
                      child:
                          Text('No challenges available! Please create one.'),
                    ),
                  ],
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ContextMenuRegion(
                    contextMenu: QuizContextMenu(
                      orgId: user.orgId!,
                      quizId: snapshot.data![index].id!,
                      onTap: () {
                        setState(() {});
                      },
                    ),
                    child: ListTile(
                      title: Text(
                        "${snapshot.data![index].duration.toDateTime().isBefore(DateTime.now()) ? '(Expired)' : ''} ${snapshot.data![index].id}",
                        style: TextStyle(
                            color: snapshot.data![index].duration
                                    .toDateTime()
                                    .isBefore(DateTime.now())
                                ? Colors.red
                                : null),
                      ),
                      tileColor: snapshot.data![index].duration
                              .toDateTime()
                              .isBefore(DateTime.now())
                          ? AdaptiveTheme.of(context).mode.isDark
                              ? const Color.fromARGB(255, 21, 21, 21)
                              : Colors.white
                          : null,
                      leading: const Icon(Icons.code_rounded),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoadingScreen(
                                futures: [
                                  QuizService().getQuiz(
                                      user.orgId!, snapshot.data![index].id!)
                                ],
                                onDone: (context, snapshot1) {
                                  Navigator.pop(context);
                                  ref.watch(screenProvider.notifier).pushScreen(
                                        CreateQuizScreen(
                                            quiz: snapshot1.data[0]!),
                                      );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          _createQuizButton()
        ],
      ),
    );
  }

  Widget _createQuizButton() {
    return ElevatedButton(
      onPressed: () {
        ref.watch(screenProvider.notifier).pushScreen(const CreateQuizScreen());
      },
      child: Text(
        'Create Quiz',
        style: TextStyle(
          color: ThemeUtils.getTextColorForBackground(
              Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}

class QuizContextMenu extends ConsumerStatefulWidget {
  final String orgId;
  final String quizId;
  final Function? onTap;

  const QuizContextMenu({
    super.key,
    required this.orgId,
    required this.quizId,
    required this.onTap,
  });

  @override
  createState() => _QuizContextMenuState();
}

class _QuizContextMenuState extends ConsumerState<QuizContextMenu>
    with ContextMenuStateMixin {
  @override
  Widget build(BuildContext context) {
    return cardBuilder.call(
      context,
      [
        buttonBuilder.call(
          context,
          ContextMenuButtonConfig(
            "Delete the quiz",
            icon: const Icon(
              Icons.delete_forever_sharp,
              size: 18,
              color: Colors.red,
            ),
            onPressed: () => handlePressed(
              context,
              () {
                QuizService().deleteQuiz(widget.orgId, widget.quizId);

                widget.onTap != null ? widget.onTap!() : null;
              },
            ),
          ),
        )
      ],
    );
  }
}
