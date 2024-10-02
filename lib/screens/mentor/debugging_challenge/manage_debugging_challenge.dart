import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/debugging_challenge.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/screens/mentor/debugging_challenge/create_debugging_challenge.dart';
import 'package:codecraft/screens/mentor/debugging_challenge/edit_debugging_challenge.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/debugging_challenge_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:universal_html/html.dart' as web;

class ManageDebuggingChallengesScreen extends ConsumerStatefulWidget {
  const ManageDebuggingChallengesScreen({super.key});

  @override
  _ManageDebuggingChallengeScreenState createState() =>
      _ManageDebuggingChallengeScreenState();
}

class _ManageDebuggingChallengeScreenState
    extends ConsumerState<ManageDebuggingChallengesScreen> {
  @override
  void initState() {
    super.initState();
    web.document.onContextMenu.listen((event) => event.preventDefault());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(appUserNotifierProvider).value;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Manage Debugging Challenges',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This is where debugging challenges will be edited.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            FutureBuilder<List<DebuggingChallenge>>(
              future: DebuggingChallengeService()
                  .getDebuggingChallenges(user!.orgId!),
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
                        child: Text(
                            'No debugging challenges available! Please create one.'),
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
                      contextMenu: DebuggingChallengeContextMenu(
                        orgId: user.orgId!,
                        challengeId: snapshot.data![index].id,
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
                                : null,
                          ),
                        ),
                        tileColor: snapshot.data![index].duration
                                .toDateTime()
                                .isBefore(DateTime.now())
                            ? Colors.grey[100]
                            : null,
                        leading: const Icon(Icons.bug_report_rounded),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LoadingScreen(
                                  futures: [
                                    DebuggingChallengeService()
                                        .getDebuggingChallenge(user.orgId!,
                                            snapshot.data![index].id)
                                  ],
                                  onDone: (context, snapshot1) {
                                    Navigator.pop(context);
                                    ref
                                        .watch(screenProvider.notifier)
                                        .pushScreen(
                                          EditDebuggingChallengeScreen(
                                            challenge: snapshot1.data[0]!,
                                          ),
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
            _createDebuggingChallengeButton()
          ],
        ),
      ),
    );
  }

  Widget _createDebuggingChallengeButton() {
    return ElevatedButton(
      onPressed: () {
        ref
            .watch(screenProvider.notifier)
            .pushScreen(const CreateDebuggingChallengeScreen());
      },
      child: Text(
        'Create Debugging Challenge',
        style: TextStyle(
          color: ThemeUtils.getTextColor(Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}

class DebuggingChallengeContextMenu extends ConsumerStatefulWidget {
  final String orgId;
  final String challengeId;
  final Function? onTap;

  const DebuggingChallengeContextMenu({
    super.key,
    required this.orgId,
    required this.challengeId,
    required this.onTap,
  });

  @override
  createState() => _DebuggingChallengeContextMenuState();
}

class _DebuggingChallengeContextMenuState
    extends ConsumerState<DebuggingChallengeContextMenu>
    with ContextMenuStateMixin {
  @override
  Widget build(BuildContext context) {
    return cardBuilder.call(
      context,
      [
        buttonBuilder.call(
          context,
          ContextMenuButtonConfig(
            "Delete the debugging challenge",
            icon: const Icon(
              Icons.delete_forever_sharp,
              size: 18,
              color: Colors.red,
            ),
            onPressed: () => handlePressed(
              context,
              () {
                DebuggingChallengeService()
                    .deleteDebuggingChallenge(widget.orgId, widget.challengeId);
                widget.onTap != null ? widget.onTap!() : null;
              },
            ),
          ),
        )
      ],
    );
  }
}
