import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/services/database_helper.dart';

class OrganizationDetailsApprentice extends StatelessWidget {
  final Map<String, dynamic> orgData;

  const OrganizationDetailsApprentice({super.key, required this.orgData});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          DatabaseHelper().users.doc(orgData['mentorId'] as String).snapshots(),
      builder: (context, mentorSnapshot) {
        if (mentorSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!mentorSnapshot.hasData || !mentorSnapshot.data!.exists) {
          return const Center(child: Text('Mentor details not available.'));
        }

        final mentorData = mentorSnapshot.data!.data() as Map<String, dynamic>;
        final mentorName =
            '${mentorData['firstName']} ${mentorData['lastName']}';

        return SingleChildScrollView(
          child: Column(
            children: [
              Text('Organization Name: ${orgData['orgName']}'),
              Text('Organization Description: ${orgData['orgDescription']}'),
              Text('Organization Mentor: $mentorName'),
            ],
          ),
        );
      },
    );
  }
}
