import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/debugging_challenge.dart';
import 'package:codecraft/screens/apprentice/coding_debugging/debugging_challenge_screen.dart';
import 'package:codecraft/services/debugging_challenge_service.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class DebuggingChallenges extends ConsumerStatefulWidget {
  const DebuggingChallenges({super.key});

  @override
  _DebuggingChallengesState createState() => _DebuggingChallengesState();
}

class _DebuggingChallengesState extends ConsumerState<DebuggingChallenges> {
  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(appUserNotifierProvider).value;

    if (appUser == null) {
      return const Center(
        child: Text('An error occurred, please try again later!'),
      );
    }

    if (!isInOrganization()) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'Debugging Challenges',
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
                  setState(() {});
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
        children: [
          const SizedBox(height: 20),
          const Text(
            'Debugging Challenges',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Here are the debugging challenges available for you to complete.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          if (appUser.orgId == 'default') ...[
            const Text(
              'Please join an organization to access debugging challenges.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {});
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
            StreamBuilder<List<DebuggingChallenge>>(
              stream: DebuggingChallengeService().getDebuggingChallengesStream(
                appUser.orgId!,
              ),
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
                    child: Text('No debugging challenges available!'),
                  );
                }

                final List<String> completedChallenges = ref
                        .watch(appUserNotifierProvider)
                        .value!
                        .completedDebuggingChallenges ??
                    [];

                final availableChallenges = snapshot.data!
                    .where((challenge) =>
                        !completedChallenges.contains(challenge.id))
                    .toList();

                final completedChallengesList = snapshot.data!
                    .where((challenge) =>
                        completedChallenges.contains(challenge.id))
                    .toList();

                return Column(
                  children: [
                    if (availableChallenges.isNotEmpty) ...[
                      const Text(
                        'Available Debugging Challenges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availableChallenges.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(availableChallenges[index].title),
                            subtitle: Text(
                              availableChallenges[index].instructions,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: const Icon(Icons.bug_report),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(
                                builder: (context) {
                                  return DebuggingChallengeScreen(
                                    organizationId: appUser.orgId!,
                                    challengeId: availableChallenges[index].id,
                                  );
                                },
                              ));
                            },
                          );
                        },
                      ),
                    ],
                    if (completedChallengesList.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        'Completed Debugging Challenges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: completedChallengesList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(completedChallengesList[index].id),
                            subtitle: Text(
                              completedChallengesList[index].instructions,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            leading: const Icon(Icons.check_circle),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DebuggingChallengeScreen(
                                      organizationId: appUser.orgId!,
                                      challengeId:
                                          completedChallengesList[index].id,
                                    ),
                                  ));
                            },
                          );
                        },
                      ),
                    ],
                  ],
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
