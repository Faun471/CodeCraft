import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/quiz.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/apprentice/organisation.dart';
import 'package:codecraft/screens/mentor/quizzes/completed_quiz_screen.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/widgets/viewers/quiz_viewer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

class CodingQuizzes extends ConsumerStatefulWidget {
  const CodingQuizzes({super.key});

  @override
  _QuizChallengesState createState() => _QuizChallengesState();
}

class _QuizChallengesState extends ConsumerState<CodingQuizzes> {
  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(appUserNotifierProvider).value;

    if (!isInOrganisation()) {
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Organisation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'You are not part of any organisation.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref
                    .watch(screenProvider.notifier)
                    .replaceScreen(const Organisation());
              },
              child: const Text('Join an Organization'),
            ),
          ],
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
                ref
                    .watch(screenProvider.notifier)
                    .pushScreen(const Organisation());
              },
              child: const Text('Join an Organization'),
            ),
          ],
          if (appUser.orgId != 'default')
            FutureBuilder<List<Quiz>>(
              future: QuizService().getQuizzes(appUser.orgId ?? ''),
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

                return FutureBuilder<List<String>>(
                  future: QuizService().getCompletedQuizzes(
                      FirebaseAuth.instance.currentUser!.uid),
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

                    final List<String> completedQuizzes =
                        completedSnapshot.data!;

                    final availableQuizzes = snapshot.data!
                        .where((quiz) => !completedQuizzes.contains(quiz.id))
                        .toList();

                    final completedQuizzesList = snapshot.data!
                        .where((quiz) => completedQuizzes.contains(quiz.id))
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
                          SmoothListView.builder(
                            duration: const Duration(milliseconds: 300),
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
                                trailing: const Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (context) {
                                      return QuizViewer(
                                        quiz: availableQuizzes[index],
                                        onQuizFinished: (isCompleted, quiz) {
                                          if (isCompleted) {
                                            QuizService()
                                                .markQuizAsCompleted(quiz.id!);
                                          }

                                          Navigator.pop(context);

                                          setState(() {});
                                        },
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
                          SmoothListView.builder(
                            duration: const Duration(milliseconds: 300),
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
                                      builder: (context) => CompletedQuizScreen(
                                          quiz: completedQuizzesList[index]),
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

  bool isInOrganisation() {
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
