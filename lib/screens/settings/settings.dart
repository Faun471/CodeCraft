import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: [
            SettingsGroup(
              settingsGroupTitle: "Appearance",
              items: [
                SettingsItem(
                  onTap: () => AdaptiveTheme.of(context).toggleThemeMode(),
                  icons: AdaptiveTheme.of(context).mode.isDark
                      ? Icons.dark_mode
                      : AdaptiveTheme.of(context).mode.isLight
                          ? Icons.light_mode
                          : Icons.brightness_auto_rounded,
                  title: AdaptiveTheme.of(context).mode.isDark
                      ? 'Dark Mode'
                      : AdaptiveTheme.of(context).mode.isLight
                          ? 'Light Mode'
                          : 'System Default Mode',
                ),
              ],
            ),
            SettingsGroup(
              settingsGroupTitle: "Account",
              items: [
                SettingsItem(
                  onTap: () async {
                    Dialogs.materialDialog(
                      context: context,
                      title: 'Logout',
                      msg: 'Are you sure you want to logout?',
                      color: AdaptiveTheme.of(context).mode.isLight
                          ? Colors.white
                          : const Color.fromARGB(255, 21, 21, 21),
                      lottieBuilder: Lottie.asset(
                        'assets/anim/question.json',
                        repeat: true,
                        fit: BoxFit.contain,
                        height: 200,
                        width: 200,
                      ),
                      actions: [
                        IconsButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          text: 'No',
                          iconData: Icons.close,
                          textStyle: AdaptiveTheme.of(context).mode.isLight
                              ? const TextStyle(
                                  color: Color.fromARGB(255, 21, 21, 21))
                              : const TextStyle(color: Colors.white),
                          iconColor: AdaptiveTheme.of(context).mode.isLight
                              ? const Color.fromARGB(255, 21, 21, 21)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: AdaptiveTheme.of(context).mode.isLight
                                  ? const Color.fromARGB(255, 21, 21, 21)
                                  : Colors.white,
                            ),
                          ),
                        ),
                        IconsButton(
                          onPressed: () {
                            AppUser().signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Login()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          text: 'Yes',
                          iconData: Icons.logout,
                          color: Colors.red,
                          textStyle: const TextStyle(color: Colors.white),
                          iconColor: Colors.white,
                        ),
                      ],
                    );
                  },
                  icons: Icons.exit_to_app_rounded,
                  title: "Sign Out",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
