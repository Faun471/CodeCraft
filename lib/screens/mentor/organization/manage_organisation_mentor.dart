import 'package:codecraft/screens/mentor/organization/join_requests_list.dart';
import 'package:codecraft/screens/mentor/organization/organisation_details_mentor.dart';
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

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Organization Details',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                OrganizationInviteRow(userId: auth.user!.uid),
                const SizedBox(height: 20),
                const Divider(),
                // SizedBox(
                //   width: MediaQuery.of(context).size.width * 0.75,
                //   height: 300,
                //   child: OrganizationMembersList(userId: auth.user!.uid),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}
