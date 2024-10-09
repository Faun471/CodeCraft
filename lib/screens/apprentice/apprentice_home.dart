import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/screens/apprentice/code_clash/code_clashes.dart';
import 'package:codecraft/screens/apprentice/coding_challenges/coding_challenges.dart';
import 'package:codecraft/screens/apprentice/coding_debugging/coding_debugging_challenges.dart';
import 'package:codecraft/screens/apprentice/coding_quizzes/coding_quizzes.dart';
import 'package:codecraft/screens/apprentice/map_screen.dart';
import 'package:codecraft/screens/apprentice/coding_challenges/weekly_challenges.dart';
import 'package:codecraft/screens/body.dart';
import 'package:codecraft/screens/generic/about_us.dart';
import 'package:codecraft/screens/generic/faq.dart';
import 'package:codecraft/screens/generic/new_about_us.dart';
import 'package:codecraft/screens/generic/pricing_screen.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ApprenticeHome extends ConsumerWidget {
  const ApprenticeHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.read(appUserNotifierProvider).when(
          data: (data) {
            return Scaffold(
              body: Body(
                sidebarItems: [
                  SidebarItem(
                    icon: Icons.home,
                    label: 'Home',
                    screen: const MapScreen(),
                  ),
                  SidebarItem(
                    icon: Icons.code_rounded,
                    label: 'Coding Challenges',
                    screen: const CodingChallenges(),
                  ),
                  SidebarItem(
                    icon: Icons.code_rounded,
                    label: 'Weekly Challenges',
                    screen: const WeeklyChallenges(),
                  ),
                  SidebarItem(
                      icon: Icons.bug_report,
                      label: 'Debugging Challenges',
                      screen: const DebuggingChallenges()),
                  SidebarItem(
                    icon: Icons.quiz,
                    label: 'Coding Quizzes',
                    screen: const CodingQuizzes(),
                  ),
                  SidebarItem(
                    icon: Icons.code_rounded,
                    label: 'Code Clash',
                    screen: const CodeClashes(),
                  ),
                  SidebarItem(
                    icon: Icons.people,
                    label: 'About Us',
                    screen: const AboutUs(),
                  ),
                  SidebarItem(
                    icon: Icons.people,
                    label: 'New About Us',
                    screen: const NewAboutUs(),
                  ),
                  SidebarItem(
                    icon: Icons.monetization_on,
                    label: 'Pricing',
                    screen: const PricingScreen(),
                  ),
                  SidebarItem(
                    icon: Icons.question_answer,
                    label: 'FAQs',
                    screen: const FAQsPage(),
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
                          title: 'Sign Out',
                          content: 'Are you sure you want to sign out?',
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
                              child: const Text('Sign Out'),
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
              'An error occurred.',
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
          skipLoadingOnReload: true,
        );
  }
}
