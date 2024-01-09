import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/screens/login.dart';
import 'package:codecraft/themes/dark_mode.dart';
import 'package:codecraft/themes/light_mode.dart';
import 'package:codecraft/themes/theme_utils.dart';
import 'package:codecraft/widgets/colour_scheme_button.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:provider/provider.dart';

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
              settingsGroupTitleStyle:
                  AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
              items: [
                SettingsItem(
                  onTap: () {
                    Dialogs.materialDialog(
                      color: AdaptiveTheme.of(context).brightness ==
                              Brightness.light
                          ? Colors.white
                          : const Color.fromARGB(255, 21, 21, 21),
                      context: context,
                      title: 'Theme',
                      titleAlign: TextAlign.left,
                      titleStyle: AdaptiveTheme.of(context)
                          .theme
                          .textTheme
                          .displayMedium!,
                      customViewPosition: CustomViewPosition.BEFORE_ACTION,
                      customView: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GridView.builder(
                          physics: const ClampingScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 75,
                            childAspectRatio: 1.0,
                            mainAxisSpacing: 10.0,
                            crossAxisSpacing: 10.0,
                            mainAxisExtent: 50,
                          ),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            // Define your color schemes
                            List<Color> colorSchemes = [
                              Colors.red,
                              Colors.green,
                              Colors.blue,
                              Colors.pink,
                              Colors.purple,
                              Colors.orange,
                              Colors.teal,
                              Colors.amber,
                            ];

                            bool isSelected =
                                AdaptiveTheme.of(context).theme.primaryColor ==
                                    colorSchemes[index];

                            return ColorSchemeButton(
                              color: colorSchemes[index],
                              isSelected: isSelected,
                              onSelect: () {
                                AdaptiveTheme.of(context).setTheme(
                                  light: ThemeUtils.changeThemeColor(
                                      lightTheme, colorSchemes[index]),
                                  dark: ThemeUtils.changeThemeColor(
                                      darkTheme, colorSchemes[index]),
                                  notify: true,
                                );

                                Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .updateColor(colorSchemes[index]);
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                  icons: Icons.color_lens_rounded,
                  iconStyle: IconStyle(
                    iconsColor: AdaptiveTheme.of(context).theme.primaryColor,
                    withBackground: false,
                  ),
                  title: 'Change Colour Scheme',
                ),
                SettingsItem(
                  onTap: () => AdaptiveTheme.of(context).toggleThemeMode(),
                  icons: AdaptiveTheme.of(context).mode.isDark
                      ? Icons.dark_mode
                      : AdaptiveTheme.of(context).brightness == Brightness.light
                          ? Icons.light_mode
                          : Icons.brightness_auto_rounded,
                  title: AdaptiveTheme.of(context).mode.isDark
                      ? 'Dark Mode'
                      : AdaptiveTheme.of(context).mode.isLight
                          ? 'Light Mode'
                          : 'System Default Mode',
                  iconStyle: IconStyle(
                    iconsColor:
                        AdaptiveTheme.of(context).brightness == Brightness.light
                            ? Colors.yellow
                            : const Color.fromARGB(255, 21, 21, 21),
                    withBackground: false,
                  ),
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
                      color: AdaptiveTheme.of(context).brightness ==
                              Brightness.light
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
                          textStyle: AdaptiveTheme.of(context).brightness ==
                                  Brightness.light
                              ? const TextStyle(
                                  color: Color.fromARGB(255, 21, 21, 21))
                              : const TextStyle(color: Colors.white),
                          iconColor: AdaptiveTheme.of(context).brightness ==
                                  Brightness.light
                              ? const Color.fromARGB(255, 21, 21, 21)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: AdaptiveTheme.of(context).brightness ==
                                      Brightness.light
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
                  iconStyle: IconStyle(
                    iconsColor:
                        AdaptiveTheme.of(context).brightness == Brightness.light
                            ? Colors.red
                            : Colors.white,
                    withBackground: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
