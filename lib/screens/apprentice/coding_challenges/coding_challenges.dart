import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/apprentice/coding_challenges/coding_challenge_screen.dart';
import 'package:codecraft/screens/apprentice/organisation/organisation_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CodingChallenges extends ConsumerStatefulWidget {
  const CodingChallenges({super.key});

  @override
  _CodingChallengesState createState() => _CodingChallengesState();
}

class _CodingChallengesState extends ConsumerState<CodingChallenges> {
  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(appUserNotifierProvider).value;

    if (appUser == null) {
      return const Center(
        child: Text('An error occurred, please try again later!'),
      );
    }

    if (!isInOrganisation()) {
      return SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Coding Challenges',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .watch(screenProvider.notifier)
                          .replaceScreen(const OrganisationScreen());
                    },
                    child: Text(
                      'Join an Organization',
                      style: TextStyle(
                        color: ThemeUtils.getTextColor(
                            Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              )
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
            'Coding Challenges',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Here are the coding challenges available for you to complete.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          if (appUser.orgId == 'default') ...[
            const Text(
              'Please join an organization to access coding challenges.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ref
                    .watch(screenProvider.notifier)
                    .pushScreen(const OrganisationScreen());
              },
              child: Text(
                'Join an Organization',
                style: TextStyle(
                  color:
                      ThemeUtils.getTextColor(Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
          if (appUser.orgId != 'Default')
            StreamBuilder<List<Challenge>>(
              stream: ChallengeService().getChallengesStream(appUser.orgId!),
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
                    child: Text('No challenges available!'),
                  );
                }

                snapshot.data!.removeWhere((challenge) =>
                    challenge.duration.toDateTime().isBefore(DateTime.now()));

                final List<String> completedChallenges = ref
                        .watch(appUserNotifierProvider)
                        .value!
                        .completedChallenges ??
                    [];

                snapshot.data!.removeWhere(
                  (challenge) => completedChallenges.contains(challenge.id),
                );

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data![index].id),
                      subtitle: Text(
                        snapshot.data![index].instructions,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: const Icon(Icons.code_rounded),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ChallengeScreen(
                                challenge: snapshot.data![index]);
                          },
                        ));
                      },
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
