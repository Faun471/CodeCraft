import 'package:codecraft/models/organisation.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrganisationPanel extends ConsumerStatefulWidget {
  final String organisation;

  const OrganisationPanel({
    super.key,
    required this.organisation,
  });

  @override
  _OrganisationPanelState createState() => _OrganisationPanelState();
}

class _OrganisationPanelState extends ConsumerState<OrganisationPanel> {
  final db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Organisation',
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 20),
          _buildOrganisationDetails(),
        ],
      ),
    );
  }

  Widget _buildOrganisationDetails() {
    return FutureBuilder(
      future: db.getOrganisation(widget.organisation),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        }

        final organisation =
            Organisation.fromMap(snapshot.data as Map<String, dynamic>);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${organisation.orgName}'),
            Text('Description: ${organisation.orgDescription}'),
            Text('Created At: ${organisation.createdAt}'),
            Text('Mentor ID: ${organisation.mentorId}'),
            Text('Code: ${organisation.code}'),
            Text('Apprentices: ${organisation.apprentices}'),
          ],
        );
      },
    );
  }
}
