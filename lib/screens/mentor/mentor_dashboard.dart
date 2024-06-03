import 'package:codecraft/screens/mentor/create_challenge_screen.dart';
import 'package:codecraft/screens/mentor/manage_requests.dart';
import 'package:flutter/material.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  _MentorDashboardState createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentor Dashboard'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ManageRequestsScreen()));
              },
              child: const Text('Manage Requests'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CreateChallengeScreen()));
              },
              child: const Text('Create Challenge'),
            ),
          ],
        ),
      ),
    );
  }
}
