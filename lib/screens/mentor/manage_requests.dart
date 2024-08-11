import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/providers/invitation_provider.dart';
import 'package:codecraft/services/auth/auth_provider.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:smooth_list_view/smooth_list_view.dart';

class ManageRequestsScreen extends ConsumerStatefulWidget {
  const ManageRequestsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      ManageRequestsScreenState();
}

class ManageRequestsScreenState extends ConsumerState<ManageRequestsScreen> {
  late String? name;
  late Map<String, dynamic> organisation = {};
  late Map<String, dynamic> user = {};

  @override
  Widget build(BuildContext context) {
    final joinRequestsProvider = ref.watch(invitationNotifierProvider);
    final invitationService = ref.read(invitationNotifierProvider.notifier);

    if (joinRequestsProvider.isLoading) {
      return Center(
        child: LoadingAnimationWidget.flickr(
          leftDotColor: Theme.of(context).primaryColor,
          rightDotColor: Theme.of(context).colorScheme.secondary,
          size: MediaQuery.of(context).size.width * 0.1,
        ),
      );
    }

    final joinRequests = joinRequestsProvider.requireValue.joinRequests;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Organisation Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'You are part of ',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: Future.wait([
                    DatabaseHelper()
                        .organisations
                        .where('mentorId',
                            isEqualTo:
                                ref.watch(authProvider).auth.currentUser!.uid)
                        .get(),
                    DatabaseHelper().getUserData(
                        ref.watch(authProvider).auth.currentUser!.uid),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return Center(
                        child: LoadingAnimationWidget.staggeredDotsWave(
                          color: Theme.of(context).primaryColor,
                          size: 20,
                        ),
                      );
                    }

                    organisation = (snapshot.data![0] as QuerySnapshot<Object>)
                        .docs
                        .first
                        .data() as Map<String, dynamic>;
                    user = snapshot.data![1] as Map<String, dynamic>;

                    return Text(
                      '${organisation['orgName']}!',
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    );
                  },
                ),
              ),
              const Expanded(child: SizedBox()),
              const Text(
                'Invite Code:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              FutureBuilder(
                future: ref
                    .watch(invitationServiceProvider.notifier)
                    .getCurrentCode(FirebaseAuth.instance.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: LoadingAnimationWidget.staggeredDotsWave(
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    );
                  }

                  return CopiableText(text: snapshot.data as String);
                },
              ),
              ElevatedButton(
                onPressed: () {
                  invitationService.createNewInvitation(
                      FirebaseAuth.instance.currentUser!.uid, user['orgId']);

                  setState(() {});
                },
                child: const Text('Generate New Code'),
              ),
            ],
          ),
          SmoothListView.builder(
            shrinkWrap: true,
            duration: const Duration(milliseconds: 200),
            itemCount: joinRequests.length,
            itemBuilder: (context, index) {
              final request = joinRequests[index];
              return ListTile(
                title: getRequesterName(request['apprenticeId']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      onPressed: () {
                        invitationService.updateRequestStatus(
                            request['id'], 'accepted');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        invitationService.updateRequestStatus(
                            request['id'], 'rejected');
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getRequesterName(String apprenticeId) {
    return FutureBuilder(
      future: DatabaseHelper().users.doc(apprenticeId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return LoadingAnimationWidget.flickr(
            leftDotColor: Theme.of(context).primaryColor,
            rightDotColor: Theme.of(context).colorScheme.secondary,
            size: MediaQuery.of(context).size.width * 0.1,
          );
        }

        return Text(
            '${snapshot.data!['firstName']} ${snapshot.data!['lastName']}');
      },
    );
  }
}

class CopiableText extends StatefulWidget {
  final String text;

  const CopiableText({super.key, required this.text});

  @override
  _CopiableTextState createState() => _CopiableTextState();
}

class _CopiableTextState extends State<CopiableText> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (_isCopied) return;
        Clipboard.setData(ClipboardData(text: widget.text));
        setState(() {
          _isCopied = true;
        });
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isCopied = false;
        });
      },
      child: _isCopied
          ? const Row(
              children: [
                Icon(Icons.check),
                SizedBox(width: 4),
                Text('Copied!'),
              ],
            )
          : Text(
              widget.text,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
    );
  }
}
