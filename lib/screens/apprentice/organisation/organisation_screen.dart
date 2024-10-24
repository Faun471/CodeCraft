import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/organisation.dart';
import 'package:codecraft/screens/apprentice/organisation/join_organisation.dart';
import 'package:codecraft/screens/apprentice/organisation/organisation_details_apprentice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/services/database_helper.dart';

class OrganizationScreen extends ConsumerWidget {
  const OrganizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(appUserNotifierProvider);

    return userAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Center(child: Text('Error: $error')),
      data: (user) {
        final isInOrg = user.orgId != null &&
            user.orgId!.isNotEmpty &&
            user.orgId != DatabaseHelper.defaultOrgId;

        if (!isInOrg) {
          return const JoinOrganization();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            return StreamBuilder<DocumentSnapshot>(
              stream:
                  DatabaseHelper().organizations.doc(user.orgId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
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
                return OrganizationCard(
                  organization: Organization.fromMap(orgData),
                );
              },
            );
          },
        );
      },
    );
  }
}
