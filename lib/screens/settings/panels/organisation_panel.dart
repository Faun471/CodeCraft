import 'package:codecraft/models/organisation.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganizationPanel extends ConsumerStatefulWidget {
  final String organization;

  const OrganizationPanel({
    super.key,
    required this.organization,
  });

  @override
  _OrganizationPanelState createState() => _OrganizationPanelState();
}

class _OrganizationPanelState extends ConsumerState<OrganizationPanel> {
  final db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organization',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          _buildOrganizationDetails(),
        ],
      ),
    );
  }

  Widget _buildOrganizationDetails() {
    return FutureBuilder(
      future: db.getOrganization(widget.organization),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        }

        final organization =
            Organization.fromMap(snapshot.data as Map<String, dynamic>);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${organization.orgName}'),
            Text('Description: ${organization.orgDescription}'),
            Text('Created At: ${organization.createdAt}'),
            Text('Mentor ID: ${organization.mentorId}'),
            Text('Code: ${organization.code}'),
            Text('Apprentices: ${organization.apprentices}'),
          ],
        );
      },
    );
  }
}
