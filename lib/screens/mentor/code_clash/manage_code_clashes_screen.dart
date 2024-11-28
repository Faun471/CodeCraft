import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/apprentice/code_clash/code_clash_results_screen.dart';
import 'package:codecraft/screens/mentor/code_clash/create_code_clash.dart';
import 'package:codecraft/screens/mentor/code_clash/start_code_clash_screen.dart';
import 'package:codecraft/services/code_clash_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:universal_html/html.dart' as web;

class ManageCodeClashesScreen extends ConsumerStatefulWidget {
  const ManageCodeClashesScreen({super.key});

  @override
  _ManageCodeClashesScreenState createState() =>
      _ManageCodeClashesScreenState();
}

class _ManageCodeClashesScreenState
    extends ConsumerState<ManageCodeClashesScreen> {
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
              'Manage Code Clashes',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            StreamBuilder<List<CodeClash>>(
              stream: CodeClashService().getCodeClashesStream(user!.orgId!),
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
                        child: Text(
                            'No code clashes available! Please create one.'),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final codeClash = snapshot.data![index];
                    return ContextMenuRegion(
                      contextMenu: CodeClashContextMenu(
                        orgId: user.orgId!,
                        codeClash: codeClash,
                        codeClashStatus: codeClash.status,
                        onTap: () {
                          setState(() {});
                        },
                      ),
                      child: ListTile(
                        title: Text(
                          codeClash.id,
                        ),
                        onTap: () {
                          if (codeClash.status == 'pending') {
                            _navigateToStartScreen(context, codeClash, ref);
                          } else {
                            _navigateToLeaderboardScreen(
                                context, codeClash, ref);
                          }
                        },
                        subtitle: Text('Status: ${codeClash.status}'),
                        leading: const Icon(Icons.code_rounded),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: AdaptiveTheme.of(context).mode.isDark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              onPressed: () => _navigateToEditScreen(
                                  context, codeClash, ref),
                            ),
                            IconButton(
                              icon: Icon(codeClash.status == 'pending'
                                  ? Icons.play_arrow
                                  : Icons.visibility),
                              onPressed: codeClash.status == 'pending'
                                  ? () => _navigateToStartScreen(
                                      context, codeClash, ref)
                                  : () => _navigateToLeaderboardScreen(
                                      context, codeClash, ref),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),
            _createCodeClashButton()
          ],
        ),
      ),
    );
  }

  Widget _createCodeClashButton() {
    return ElevatedButton(
      onPressed: () {
        ref
            .watch(screenProvider.notifier)
            .pushScreen(const CreateCodeClashScreen());
      },
      child: Text(
        'Create a Code Clash',
        style: TextStyle(
          color: ThemeUtils.getTextColorForBackground(
              Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}

class CodeClashContextMenu extends ConsumerStatefulWidget {
  final String orgId;
  final CodeClash codeClash;
  final String codeClashStatus;
  final Function? onTap;

  const CodeClashContextMenu({
    super.key,
    required this.orgId,
    required this.codeClash,
    required this.codeClashStatus,
    required this.onTap,
  });

  @override
  createState() => _CodeClashContextMenuState();
}

class _CodeClashContextMenuState extends ConsumerState<CodeClashContextMenu>
    with ContextMenuStateMixin {
  @override
  Widget build(BuildContext context) {
    return cardBuilder.call(
      context,
      [
        buttonBuilder.call(
          context,
          ContextMenuButtonConfig(
            "Edit",
            icon: Icon(
              Icons.edit,
              size: 18,
              color: AdaptiveTheme.of(context).mode.isDark
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () => handlePressed(
              context,
              () {
                Navigator.of(context).pop();
                _navigateToEditScreen(context, widget.codeClash, ref);
              },
            ),
          ),
        ),
        buttonBuilder.call(
          context,
          ContextMenuButtonConfig(
            widget.codeClashStatus == 'pending' ? "Start" : "View Results",
            icon: Icon(
              widget.codeClashStatus == 'pending'
                  ? Icons.play_arrow
                  : Icons.visibility,
              size: 18,
              color: AdaptiveTheme.of(context).mode.isDark
                  ? Colors.white
                  : Colors.black,
            ),
            onPressed: () => handlePressed(
              context,
              () {
                Navigator.of(context).pop();
                if (widget.codeClashStatus == 'pending') {
                  _navigateToStartScreen(context, widget.codeClash, ref);
                } else {
                  _navigateToLeaderboardScreen(context, widget.codeClash, ref);
                }
              },
            ),
          ),
        ),
        buttonBuilder.call(
          context,
          ContextMenuButtonConfig(
            "Delete",
            icon: const Icon(
              Icons.delete_forever_sharp,
              size: 18,
              color: Colors.red,
            ),
            onPressed: () => handlePressed(
              context,
              () {
                CodeClashService()
                    .deleteCodeClash(widget.orgId, widget.codeClash.id);
                widget.onTap != null ? widget.onTap!() : null;
              },
            ),
          ),
        ),
      ],
    );
  }
}

void _navigateToEditScreen(
    BuildContext context, CodeClash codeClash, WidgetRef ref) {
  ref.watch(screenProvider.notifier).pushScreen(
        CreateCodeClashScreen(codeClash: codeClash),
      );
}

void _navigateToStartScreen(
    BuildContext context, CodeClash codeClash, WidgetRef ref) {
  ref.watch(screenProvider.notifier).pushScreen(
        StartCodeClashScreen(codeClash: codeClash),
      );
}

void _navigateToLeaderboardScreen(
    BuildContext context, CodeClash codeClash, WidgetRef ref) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => CodeClashResultsScreen(
        codeClashId: codeClash.id,
        organizationId: ref.watch(appUserNotifierProvider).value!.orgId!,
      ),
    ),
  );
}
