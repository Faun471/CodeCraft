import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/challenge.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/screens/mentor/challenges/create_challenge_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:universal_html/html.dart' as web;

class ManageChallengesScreen extends ConsumerStatefulWidget {
  const ManageChallengesScreen({super.key});

  @override
  _ManageChallengeScreenState createState() => _ManageChallengeScreenState();
}

class _ManageChallengeScreenState
    extends ConsumerState<ManageChallengesScreen> {
  @override
  void initState() {
    super.initState();

    web.document.onContextMenu.listen((event) => event.preventDefault());
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.read(appUserNotifierProvider).value;

    return ContextMenuOverlay(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'Manage Challenges',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'This is where challenges will be edited.',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<Challenge>>(
              stream: ChallengeService().getChallengesStream(user!.orgId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.flickr(
                      leftDotColor: Theme.of(context).primaryColor,
                      rightDotColor: Theme.of(context).colorScheme.secondary,
                      size: MediaQuery.of(context).size.width * 0.1,
                    ),
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
                      contextMenu: ContextMenu(
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
                        subtitle: Text(
                          snapshot.data![index].instructions,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,
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
                          ref.watch(screenProvider.notifier).pushScreen(
                                LoadingScreen(
                                  futures: [
                                    ChallengeService().getChallenge(
                                      user.orgId!,
                                      snapshot.data![index].id,
                                    )
                                  ],
                                  onDone: (context, snapshot1, ref) {
                                    ref
                                        .watch(screenProvider.notifier)
                                        .replaceScreen(
                                          CreateChallengeScreen(
                                            challenge: snapshot1.data[0]!,
                                          ),
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
            _createChallengeButton()
          ],
        ),
      ),
    );
  }

  Widget _createChallengeButton() {
    return ElevatedButton(
      onPressed: () {
        ref
            .watch(screenProvider.notifier)
            .pushScreen(const CreateChallengeScreen());
      },
      child: Text(
        'Create Challenge',
        style: TextStyle(
          color: ThemeUtils.getTextColorForBackground(
              Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}

class ContextMenu extends ConsumerStatefulWidget {
  final String orgId;
  final String challengeId;
  final Function? onTap;

  const ContextMenu({
    super.key,
    required this.orgId,
    required this.challengeId,
    required this.onTap,
  });

  @override
  createState() => _ChallengeContextMenuState();
}

class _ChallengeContextMenuState extends ConsumerState<ContextMenu>
    with ContextMenuStateMixin {
  @override
  Widget build(BuildContext context) {
    return cardBuilder.call(
      context,
      [
        buttonBuilder.call(
          context,
          ContextMenuButtonConfig(
            "Delete the challenge",
            icon: const Icon(
              Icons.delete_forever_sharp,
              size: 18,
              color: Colors.red,
            ),
            onPressed: () => handlePressed(
              context,
              () {
                ChallengeService()
                    .deleteChallenge(widget.orgId, widget.challengeId);

                widget.onTap != null ? widget.onTap!() : null;
              },
            ),
          ),
        )
      ],
    );
  }
}
