import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/services/code_clash_service.dart';
import 'package:codecraft/screens/apprentice/code_clash/code_clash_screen.dart';

class CodeClashLobbyScreen extends ConsumerStatefulWidget {
  final CodeClash codeClash;

  const CodeClashLobbyScreen({super.key, required this.codeClash});

  @override
  _CodeClashLobbyScreenState createState() => _CodeClashLobbyScreenState();
}

class _CodeClashLobbyScreenState extends ConsumerState<CodeClashLobbyScreen> {
  late Stream<CodeClash> _codeClashStream;

  @override
  void initState() {
    super.initState();
    final appUser = ref.read(appUserNotifierProvider).value;
    if (appUser != null) {
      _codeClashStream = CodeClashService().getCodeClashStream(
        appUser.orgId!,
        widget.codeClash.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appUser = ref.read(appUserNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Lobby: ${widget.codeClash.title}',
          style: TextStyle(
            color: ThemeUtils.getTextColor(
              Theme.of(context).primaryColor,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              if (appUser != null) {
                _leaveCodeClash(
                  widget.codeClash.id,
                  FirebaseAuth.instance.currentUser!.uid,
                );

                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<CodeClash>(
        stream: _codeClashStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final codeClash = snapshot.data;
          if (codeClash == null) {
            return const Center(child: Text('Code Clash not found'));
          }

          if (codeClash.status == 'active') {
            // Redirect to CodeClashScreen when the clash starts
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => CodeClashScreen(codeClash: codeClash),
              ));
            });
          }

          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width < 600
                  ? MediaQuery.of(context).size.width
                  : 600,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: codeClash.participants.length,
                      itemBuilder: (context, index) {
                        final participant = codeClash.participants[index];

                        return Card(
                          child: ListTile(
                            leading: ClipOval(
                              child: Container(
                                color: Theme.of(context).primaryColor,
                                width: 50,
                                height: 50,
                                child: CachedNetworkImage(
                                  imageUrl: participant.photoURL ?? '',
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(participant.displayName),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Waiting for the Code Clash to start...',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _leaveCodeClash(String codeClashId, String userId) async {
    await CodeClashService().leaveCodeClash(codeClashId, userId);
  }
}
