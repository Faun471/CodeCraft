import 'package:codecraft/screens/mentor/organisation/copiable_text.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/services/database_helper.dart';

class OrganisationInviteRow extends ConsumerWidget {
  final String userId;

  const OrganisationInviteRow({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgStream = DatabaseHelper().getOrganisationStreamForMentor(userId);
    final userStream = DatabaseHelper().getUserStream(userId);
    final invitationService = ref.watch(invitationServiceProvider.notifier);

    return StreamBuilder(
      stream: orgStream,
      builder: (context, orgSnapshot) {
        return StreamBuilder(
          stream: userStream,
          builder: (context, userSnapshot) {
            if (!orgSnapshot.hasData || !userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = userSnapshot.data!.data()! as Map<String, dynamic>;

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 4),
                Row(
                  children: [
                    const Text('Invite Code: '),
                    StreamBuilder<String>(
                      stream: invitationService.getCurrentCodeStream(userId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }
                        return CopiableText(text: snapshot.data!);
                      },
                    ),
                    const Expanded(child: SizedBox()),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () => invitationService.createInvitation(
                          userId, user['orgId']),
                      child: Text(
                        'Generate New Code',
                        style: TextStyle(
                          color: ThemeUtils.getTextColor(
                              Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }
}
