import 'package:codecraft/screens/mentor/organisation/join_requests_list.dart';
import 'package:codecraft/screens/mentor/organisation/organisation_details_mentor.dart';
import 'package:codecraft/services/auth/auth_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageRequestsScreen extends ConsumerWidget {
  const ManageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.refresh(authProvider);

    return authState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (auth) {
        if (auth.user == null) {
          return Center(child: Text('Not authenticated, auth is $auth'));
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Organisation Details',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 20),
                OrganisationInviteRow(userId: auth.user!.uid),
                const SizedBox(height: 10),
                JoinRequestsList(userId: auth.user!.uid),
              ],
            ),
          ),
        );
      },
    );
  }
}
