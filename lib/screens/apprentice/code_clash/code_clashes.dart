import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/screens/apprentice/code_clash/code_clash_details.dart';
import 'package:codecraft/screens/apprentice/code_clash/code_clash_lobby_screen.dart';
import 'package:codecraft/screens/apprentice/code_clash/code_clash_results_screen.dart';
import 'package:codecraft/services/code_clash_service.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CodeClashes extends ConsumerStatefulWidget {
  const CodeClashes({super.key});

  @override
  _CodeClashesScreenState createState() => _CodeClashesScreenState();
}

class _CodeClashesScreenState extends ConsumerState<CodeClashes> {
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Code Clashes',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
            'Code Clashes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Here are the code clashes available for you to join.',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          StreamBuilder<List<CodeClash>>(
            stream: CodeClashService().getCodeClashesStream(appUser.orgId!),
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
                  child: Text('No code clashes available!'),
                );
              }

              final filteredClashes = snapshot.data!
                  .where((clash) => clash.status != 'completed')
                  .toList();

              final completedClashes = snapshot.data!
                  .where((clash) => clash.status == 'completed')
                  .toList();

              return Column(
                children: [
                  if (filteredClashes.isNotEmpty) ...[
                    const Text(
                      'Active Code Clashes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredClashes.length,
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
                          onTap: () => _onCodeClashTapped(
                            snapshot.data![index],
                            appUser.id ??
                                FirebaseAuth.instance.currentUser!.uid,
                          ),
                        );
                      },
                    ),
                  ],
                  if (completedClashes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Finished Code Clashes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: completedClashes.length,
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
                          onTap: () => _onCodeClashTapped(
                            snapshot.data![index],
                            appUser.id ??
                                FirebaseAuth.instance.currentUser!.uid,
                          ),
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

  void _onCodeClashTapped(CodeClash codeClash, String userId) async {
    if (!codeClash.isUserInClash(userId)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CodeClashDetailScreen(codeClash: codeClash),
        ),
      );
      return;
    }

    final CodeClashService codeClashService = CodeClashService();

    final appUser = ref.watch(appUserNotifierProvider).value;

    // check if the user already has a submission
    if (await codeClashService.hasUserSubmitted(
      appUser!.orgId!,
      codeClash.id,
      userId,
    )) {
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CodeClashResultsScreen(
            codeClashId: codeClash.id,
            organizationId: ref.watch(appUserNotifierProvider).value!.orgId!,
          ),
        ),
      );
      return;
    }

    if (!mounted) return;

    if (codeClash.status == 'completed') {
      Utils.displayDialog(
        context: context,
        title: 'Code Clash Completed!',
        content: 'This code clash has already been completed.',
        lottieAsset: 'assets/anim/congrats.json',
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CodeClashResultsScreen(
                    codeClashId: codeClash.id,
                    organizationId:
                        ref.watch(appUserNotifierProvider).value!.orgId!,
                  ),
                ),
              );
            },
            child: const Text('View Results'),
          ),
        ],
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CodeClashLobbyScreen(codeClash: codeClash),
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
