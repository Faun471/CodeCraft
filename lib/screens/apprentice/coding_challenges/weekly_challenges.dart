import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/screens/apprentice/coding_challenges/coding_challenge_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class WeeklyChallenges extends ConsumerStatefulWidget {
  const WeeklyChallenges({super.key});

  @override
  _WeeklyChallengesState createState() => _WeeklyChallengesState();
}

class _WeeklyChallengesState extends ConsumerState<WeeklyChallenges> {
  bool _showAllLevels = true;
  String _sortBy = 'level';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Weekly Challenges',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAllLevels = !_showAllLevels;
                    });
                  },
                  child: Text(
                    _showAllLevels ? 'Show My Level' : 'Show All Levels',
                  ),
                ),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(
                        value: 'level', child: Text('Sort by Level')),
                    DropdownMenuItem(
                        value: 'name', child: Text('Sort by Name')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: ChallengeService().getChallengesStream('Weekly'),
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

                final userLevel =
                    ref.read(appUserNotifierProvider).requireValue.level ?? 1;

                // Filter out expired challenges
                var filteredChallenges = snapshot.data!
                    .where((challenge) =>
                        challenge.duration.toDateTime().isAfter(DateTime.now()))
                    .toList();

                // Filter challenges by level if not showing all levels
                if (!_showAllLevels) {
                  filteredChallenges = filteredChallenges
                      .where((challenge) =>
                          challenge.levelRequired == null ||
                          challenge.levelRequired! <= userLevel)
                      .toList();
                }

                // Sort challenges
                filteredChallenges.sort((a, b) {
                  if (_sortBy == 'level') {
                    return (a.levelRequired ?? 1)
                        .compareTo(b.levelRequired ?? 1);
                  } else {
                    return a.id.compareTo(b.id);
                  }
                });

                if (filteredChallenges.isEmpty) {
                  return const Center(
                    child: Text('No challenges available!'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredChallenges.length,
                  itemBuilder: (context, index) {
                    final challenge = filteredChallenges[index];
                    final levelDifference =
                        (challenge.levelRequired ?? 1) - userLevel;

                    Color tileColor;
                    if (levelDifference <= 0) {
                      tileColor = Colors.green.withOpacity(0.2);
                    } else if (levelDifference <= 3) {
                      tileColor = Colors.orange.withOpacity(0.2);
                    } else {
                      tileColor = Colors.red.withOpacity(0.2);
                    }

                    return ListTile(
                      title: Text(challenge.id),
                      subtitle: Text(
                        'Level: ${challenge.levelRequired ?? 'Any'}\n${challenge.instructions}',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      tileColor: tileColor,
                      leading: FutureBuilder(
                        future: ChallengeService().getCompletedChallenges(
                            FirebaseAuth.instance.currentUser!.uid),
                        builder: (context, snapshot1) {
                          if (snapshot1.connectionState !=
                              ConnectionState.done) {
                            return const CircularProgressIndicator();
                          }
                          if (snapshot1.hasError) {
                            return const Icon(Icons.error);
                          }
                          if (snapshot1.data!.contains(challenge.id)) {
                            return const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.green,
                            );
                          }
                          return const Icon(Icons.code_rounded);
                        },
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return ChallengeScreen(challenge: challenge);
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
      ),
    );
  }
}
