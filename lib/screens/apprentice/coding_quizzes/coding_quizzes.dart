import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/apprentice/coding_quizzes/coding_quiz_screen.dart';
import 'package:codecraft/screens/apprentice/coding_quizzes/completed_quiz_screen.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CodingQuizzes extends ConsumerStatefulWidget {
  const CodingQuizzes({super.key});

  @override
  _QuizChallengesState createState() => _QuizChallengesState();
}

class _QuizChallengesState extends ConsumerState<CodingQuizzes> {
  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(appUserNotifierProvider).value;

    if (!isInOrganization()) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Coding Quizzes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'You are not part of any organization.',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  ref
                      .watch(screenProvider.notifier)
                      .pushScreen(SettingsScreen());
                },
                child: Text(
                  'Join an Organization',
                  style: TextStyle(
                    color: ThemeUtils.getTextColorForBackground(
                        Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Quiz Challenges',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Here are the quiz challenges available for you to complete.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          if (appUser!.orgId == 'default') ...[
            const Text(
              'Please join an organization to access quiz challenges.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref.watch(screenProvider.notifier).pushScreen(SettingsScreen());
              },
              child: Text(
                'Join an Organization',
                style: TextStyle(
                  color: ThemeUtils.getTextColorForBackground(
                      Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
          if (appUser.orgId != 'default')
            StreamBuilder<List<Quiz>>(
              stream: QuizService().getQuizzesStream(appUser.orgId!),
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
                  return const Center(
                    child: Text('No quizzes available!'),
                  );
                }

                return StreamBuilder<List<QuizResult>>(
                  stream: QuizService().streamCompletedQuizzes(),
                  builder: (context, completedSnapshot) {
                    if (completedSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return LoadingAnimationWidget.flickr(
                        leftDotColor: Theme.of(context).primaryColor,
                        rightDotColor: Theme.of(context).colorScheme.secondary,
                        size: MediaQuery.of(context).size.width * 0.1,
                      );
                    }

                    if (completedSnapshot.hasError) {
                      return const Center(
                        child:
                            Text('An error occurred, please try again later!'),
                      );
                    }

                    final List<QuizResult> completedQuizzes =
                        completedSnapshot.data!;

                    final availableQuizzes = snapshot.data!
                        .where((quiz) => !completedQuizzes.any(
                            (completedQuiz) => completedQuiz.id == quiz.id))
                        .where((quiz) =>
                            quiz.duration.toDateTime().isAfter(DateTime.now()))
                        .toList();

                    final completedQuizzesList = snapshot.data!
                        .where((quiz) => completedQuizzes.any(
                            (completedQuiz) => completedQuiz.id == quiz.id))
                        .toList();

                    return Column(
                      children: [
                        if (availableQuizzes.isNotEmpty) ...[
                          const Text(
                            'Available Quizzes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: availableQuizzes.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(availableQuizzes[index].title),
                                subtitle: Text(
                                  'Questions: ${availableQuizzes[index].questions.length}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: const Icon(Icons.quiz),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AutoSizeText(
                                      availableQuizzes[index]
                                          .duration
                                          .toDateTime()
                                          .toString(),
                                    ),
                                    const SizedBox(width: 10),
                                    const Icon(Icons.arrow_forward_ios),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return QuizScreen(
                                        quizId: availableQuizzes[index].id!,
                                      );
                                    },
                                  ));
                                },
                              );
                            },
                          ),
                        ],
                        if (completedQuizzesList.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Completed Quizzes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: completedQuizzesList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(completedQuizzesList[index].title),
                                subtitle: Text(
                                  'Questions: ${completedQuizzesList[index].questions.length}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                leading: const Icon(Icons.check_circle),
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => QuizResultsScreen(
                                        quiz: completedQuizzesList[index],
                                        quizResult: completedQuizzes.firstWhere(
                                            (quizResult) =>
                                                quizResult.id ==
                                                completedQuizzesList[index].id),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  bool isInOrganization() {
    final user = ref.watch(appUserNotifierProvider).value;

    if (user!.orgId == null) {
      return false;
    }

    if (user.orgId!.isEmpty) {
      return false;
    }

    if (user.orgId == DatabaseHelper.defaultOrgId) {
      return false;
    }

    return true;
  }
}
