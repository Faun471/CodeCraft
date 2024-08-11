import 'package:codecraft/screens/apprentice/challenge_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

class WeeklyChallenges extends ConsumerStatefulWidget {
  const WeeklyChallenges({super.key});

  @override
  _WeeklyChallengesState createState() => _WeeklyChallengesState();
}

class _WeeklyChallengesState extends ConsumerState<WeeklyChallenges> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
          const Text(
            'This is where the weekly challenges will be displayed.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          FutureBuilder(
              future: ChallengeService().getChallenges('Weekly'),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
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

                snapshot.data!.removeWhere((challenge) =>
                    challenge.duration.toDateTime().isBefore(DateTime.now()));

                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No challenges available!'),
                  );
                }

                return SmoothListView.builder(
                  duration: const Duration(milliseconds: 300),
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
                          if (snapshot1.data!
                              .contains(snapshot.data![index].id)) {
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
                            return ChallengeScreen(
                                challenge: snapshot.data![index]);
                          },
                        ));
                      },
                    );
                  },
                );
              }),
        ],
      ),
    );
  }
}
