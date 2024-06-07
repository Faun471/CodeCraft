import 'package:codecraft/screens/apprentice/coding_challenges.dart';
import 'package:codecraft/screens/apprentice/modules.dart';
import 'package:codecraft/screens/apprentice/organisation.dart';
import 'package:codecraft/screens/apprentice/weekly_challenges.dart';
import 'package:codecraft/screens/body.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApprenticeHome extends ConsumerWidget {
  const ApprenticeHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Body(sidebarItems: [
      SidebarItem(
        icon: Icons.home,
        label: 'Home',
        screen: const Modules(),
      ),
      SidebarItem(
        icon: Icons.people,
        label: 'Organisation',
        screen: const Organisation(),
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
        icon: Icons.settings,
        label: 'Settings',
        screen: const Settings(),
      ),
    ]);
  }
}
