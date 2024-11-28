import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/screens/body.dart';
import 'package:codecraft/screens/generic/faq.dart';
import 'package:codecraft/screens/generic/leaderboards.dart';
import 'package:codecraft/screens/generic/new_about_us.dart';
import 'package:codecraft/screens/generic/pricing_screen.dart';
import 'package:codecraft/screens/mentor/code_clash/manage_code_clashes_screen.dart';
import 'package:codecraft/screens/mentor/debugging_challenge/manage_debugging_challenge.dart';
import 'package:codecraft/screens/mentor/organization/manage_organisation_mentor.dart';
import 'package:codecraft/screens/mentor/quizzes/manage_quizzes_screen.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'mentor_dashboard.dart';
import 'challenges/manage_challenges_screen.dart';

class MentorHome extends ConsumerStatefulWidget {
  const MentorHome({super.key});

  @override
  _MentorHomeState createState() => _MentorHomeState();
}

class _MentorHomeState extends ConsumerState<MentorHome> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(appUserNotifierProvider).when(
      data: (data) {
        return Scaffold(
          body: Body(
            sidebarItems: [
              SidebarItem(
                icon: Icons.home,
                label: 'Home',
                screen: const MentorDashboard(),
              ),
              SidebarItem(
                label: 'Organization',
                icon: Icons.people,
                screen: const ManageOrganizationScreen(),
                subItems: [
                  SidebarItem(
                    icon: Icons.leaderboard,
                    label: 'Leaderboards',
                    screen: const Leaderboards(),
                  ),
                  SidebarItem(
                    icon: Icons.people,
                    label: 'Manage Organization',
                    screen: const ManageOrganizationScreen(),
                  ),
                  SidebarItem(
                    icon: Icons.monetization_on,
                    label: 'Pricing',
                    screen: const PlanUpgradeScreen(),
                  ),
                ],
              ),
              SidebarItem(
                label: 'Challenges',
                icon: Icons.code,
                screen: const ManageChallengesScreen(),
                subItems: [
                  SidebarItem(
                    icon: Icons.code_off_outlined,
                    label: 'Manage Coding Challenges',
                    screen: const ManageChallengesScreen(),
                  ),
                  SidebarItem(
                    icon: Icons.lightbulb,
                    label: 'Manage Coding Quizzes',
                    screen: const ManageQuizzesScreen(),
                  ),
                  SidebarItem(
                    icon: Icons.bug_report,
                    label: 'Manage Debugging Challenges',
                    screen: const ManageDebuggingChallengesScreen(),
                  ),
                  SidebarItem(
                    icon: Icons.code_outlined,
                    label: 'Manage Code Clashes',
                    screen: const ManageCodeClashesScreen(),
                  ),
                ],
              ),
              SidebarItem(
                icon: Icons.info,
                label: 'Information',
                screen: NewAboutUs(),
                subItems: [
                  SidebarItem(
                    icon: Icons.people,
                    label: 'About Us',
                    screen: const NewAboutUs(),
                  ),
                  SidebarItem(
                    icon: Icons.question_answer,
                    label: 'FAQs',
                    screen: const FAQsPage(),
                  ),
                ],
              ),
              SidebarItem(
                icon: Icons.settings,
                label: 'Settings',
                screen: const SettingsScreen(
                  initialTab: 'User Profile',
                ),
                subItems: [
                  SidebarItem(
                    icon: Icons.person,
                    label: 'User Profile',
                    screen: const SettingsScreen(),
                  ),
                  SidebarItem(
                    icon: Icons.palette,
                    label: 'Appearance',
                    screen: const SettingsScreen(
                      initialTab: 'Appearance',
                    ),
                  ),
                  SidebarItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    screen: const SettingsScreen(),
                    onTap: () => Utils.displayDialog(
                      context: context,
                      title: 'Log Out',
                      content: 'Are you sure you want to log out?',
                      lottieAsset: 'assets/anim/question.json',
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            FirebaseAuth.instance.signOut();
                          },
                          child: const Text('Log Out'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      error: (object, stacktrace) {
        return const Text(
          'An error occured.',
          style: TextStyle(
            color: Colors.red,
            fontSize: 32,
          ),
        );
      },
      loading: () {
        return LoadingAnimationWidget.flickr(
          leftDotColor: Theme.of(context).primaryColor,
          rightDotColor: Theme.of(context).colorScheme.secondary,
          size: 200,
        );
      },
    );
  }
}
