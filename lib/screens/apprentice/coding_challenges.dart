import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/screens/apprentice/challenge_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CodingChallenges extends StatefulWidget {
  const CodingChallenges({super.key});

  @override
  _CodingChallengesState createState() => _CodingChallengesState();
}

class _CodingChallengesState extends State<CodingChallenges> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Coding Challenges',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 20),
          FutureBuilder<List<Challenge>>(
            future: ChallengeService()
                .getChallenges(AppUser.instance.data['orgID'] ?? ''),
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

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(snapshot.data![index].id),
                    subtitle: Text(snapshot.data![index].instructions),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChallengeScreen(
                                  challenge: snapshot.data![index])));
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
}
