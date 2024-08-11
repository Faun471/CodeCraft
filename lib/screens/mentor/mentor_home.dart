import 'package:codecraft/screens/body.dart';
import 'package:codecraft/screens/mentor/manage_requests.dart';
import 'package:codecraft/screens/mentor/quizzes/create_quiz_screen.dart';
import 'package:codecraft/screens/mentor/quizzes/manage_quizzes_screen.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mentor_dashboard.dart';
import 'challenges/manage_challenges_screen.dart';

class MentorHome extends ConsumerWidget {
  const MentorHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Body(
        sidebarItems: [
          SidebarItem(
            icon: Icons.home,
            label: 'Home',
            screen: const MentorDashboard(),
          ),
          SidebarItem(
            icon: Icons.people,
            label: 'Manage Organisation',
            screen: const ManageRequestsScreen(),
          ),
          SidebarItem(
            icon: Icons.code_off_outlined,
            label: 'Manage Challenges',
            screen: const ManageChallengesScreen(),
          ),
          SidebarItem(
            icon: Icons.lightbulb,
            label: 'Manage Quizzes',
            screen: const ManageQuizzesScreen(),
          ),
          SidebarItem(
            icon: Icons.settings,
            label: 'Settings',
            screen: const Settings(),
          ),
        ],
      ),
    );
  }
}
