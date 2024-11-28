import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/organisation.dart';
import 'package:codecraft/screens/mentor/organization/organisation_invite_row.dart';
import 'package:codecraft/screens/mentor/organization/organization_members_list.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/screens/apprentice/organisation/organisation_card.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ManageOrganizationScreen extends ConsumerWidget {
  const ManageOrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserNotifierProvider);

    return appUser.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (appUser) {
        return FutureBuilder(
          future: DatabaseHelper().organizations.doc(appUser.orgId!).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.flickr(
                  leftDotColor: Theme.of(context).primaryColor,
                  rightDotColor: Theme.of(context).primaryColor,
                  size: MediaQuery.of(context).size.width * 0.2,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(
                child: Text('Organization details not available.'),
              );
            }

            final orgData = snapshot.data!.data() as Map<String, dynamic>;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    OrganizationInviteRow(userId: appUser.id!),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    OrganizationCard(
                      organization: Organization.fromMap(orgData),
                    ),
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 10),
                    OrganizationMembersList(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
