import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/settings/panels/appearance_panel.dart';
import 'package:codecraft/screens/settings/panels/user_profile_panel.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedTabProvider = StateProvider<String>((ref) => 'User Profile');

class SettingsScreen extends ConsumerStatefulWidget {
  final String initialTab;

  const SettingsScreen({super.key, this.initialTab = 'User Profile'});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return isSmallScreen ? _buildMobileLayout() : _buildDesktopLayout();
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildSettingsPanel(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 250,
          child: _buildSettings(),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: _buildSettingsPanel(),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return ListView(
      shrinkWrap: true,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        const Divider(),
        const SizedBox(height: 10),
        ListTile(
          title: const Text('User Profile'),
          onTap: () => _onSelected('User Profile'),
          selected: widget.initialTab == 'User Profile',
        ),
        // ListTile(
        //   title: const Text('Organization'),
        //   onTap: () => _onSelected('Organization'),
        //   selected: widget.initialTab == 'Organization',
        // ),
        ListTile(
          title: const Text('Appearance'),
          onTap: () => _onSelected('Appearance'),
          selected: widget.initialTab == 'Appearance',
        ),
        ListTile(
          title: const Text('Sign Out'),
          onTap: () {
            Utils.displayDialog(
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
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSettingsPanel() {
    Widget panel;

    switch (widget.initialTab) {
      case 'User Profile':
        panel = const UserProfilePanel();
      // case 'Organization':
      //   panel = OrganizationPanel(
      //     organization: ref.read(appUserNotifierProvider).value!.orgId!,
      //   );
      case 'Appearance':
        panel = const AppearancePanel();
      default:
        return const SizedBox();
    }

    return SingleChildScrollView(
      child: panel,
    );
  }

  void _onSelected(String value) {
    setState(() {
      ref
          .read(screenProvider.notifier)
          .pushScreen(SettingsScreen(initialTab: value));
    });
  }
}
