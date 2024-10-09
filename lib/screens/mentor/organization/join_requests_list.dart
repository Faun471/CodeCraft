import 'package:codecraft/services/invitation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/services/database_helper.dart';

class JoinRequestsList extends ConsumerWidget {
  final String userId;

  const JoinRequestsList({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final joinRequestsStream = ref
        .watch(invitationServiceProvider.notifier)
        .getJoinRequestsStream(userId);
    final invitationService = ref.watch(invitationServiceProvider.notifier);

    return Column(
      children: [
        const SizedBox(
          height: 20,
          width: double.infinity,
        ),
        Text(
          'Pending Requests',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(
          height: 20,
          width: double.infinity,
        ),
        Container(
          color: Colors.grey[200],
          width: 800,
          height: 300,
          padding: const EdgeInsets.all(8),
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: joinRequestsStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              final joinRequests = snapshot.data ?? [];

              if (joinRequests.isEmpty) {
                return Center(child: const Text('No pending requests'));
              }

              return SingleChildScrollView(
                child: Column(
                  children: joinRequests.map((request) {
                    return ListTile(
                      title: StreamBuilder(
                        stream: DatabaseHelper()
                            .getUserStream(request['apprenticeId']),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          final userData =
                              snapshot.data!.data()! as Map<String, dynamic>;
                          return Text(
                              '${userData['firstName']} ${userData['lastName']}');
                        },
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () =>
                                invitationService.updateJoinRequestStatus(
                              request['code'],
                              request['apprenticeId'],
                              'accepted',
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                invitationService.updateJoinRequestStatus(
                              request['code'],
                              request['apprenticeId'],
                              'rejected',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
