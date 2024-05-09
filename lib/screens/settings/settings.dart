import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/loading_screen.dart';
import 'package:codecraft/screens/settings/account_edit.dart';
import 'package:codecraft/screens/account_setup/login.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/widgets/colour_scheme_button.dart';
import 'package:codecraft/widgets/custom_big_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  late User currentUser;
  late String imageUrl;
  late String displayName;
  late String email;

  @override
  void initState() {
    super.initState();

    currentUser = DatabaseHelper().auth.currentUser!;

    imageUrl = currentUser.photoURL ?? '';

    if (imageUrl.isEmpty) {
      imageUrl = 'assets/images/logo.png';
    }

    if (currentUser.displayName != null) {
      displayName = currentUser.displayName ?? '';
    } else {
      displayName = 'User';
    }

    email = currentUser.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            buildUserCard(context),
            buildAppearanceSettings(context),
            buildAccountSettings(context),
          ],
        ),
      ),
    );
  }

  Widget buildUserCard(BuildContext context) {
    return CustomBigUserCard(
      userName:
          "$displayName Lvl ${AppUser.instance.data['level'] ?? 1}",
      userProfilePic: CachedNetworkImage(
        height: 150,
        width: 150,
        alignment: Alignment.centerLeft,
        fit: BoxFit.cover,
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
        ),
      ),
      userMoreInfo: AutoSizeText(
        email,
        style: AdaptiveTheme.of(context)
            .theme
            .textTheme
            .bodySmall!
            .copyWith(color: Colors.white),
      ),
      backgroundColor: Provider.of<ThemeProvider>(context).preferredColor,
      cardActionWidget: buildSettingsItem(context),
    );
  }

  Widget buildSettingsItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SettingsItem(
        backgroundColor: Colors.black,
        icons: Icons.edit_rounded,
        title: 'Edit Profile',
        titleStyle: const TextStyle(
          color: Color.fromARGB(255, 21, 21, 21),
        ),
        subtitle: 'Change your profile details',
        subtitleStyle: const TextStyle(
          color: Color.fromARGB(255, 21, 21, 21),
        ),
        iconStyle: IconStyle(
          iconsColor: Colors.black,
          backgroundColor: Colors.white,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AccountEdit(),
          ),
        ).then((value) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await currentUser.reload();

            setState(() {});
          });
        }),
      ),
    );
  }

  Widget buildAppearanceSettings(BuildContext context) {
    return SettingsGroup(
      settingsGroupTitle: "Appearance",
      settingsGroupTitleStyle:
          AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
      items: [
        buildColorSchemeSettings(context),
        buildThemeModeSettings(context),
      ],
    );
  }

  SettingsItem buildColorSchemeSettings(BuildContext context) {
    return SettingsItem(
      onTap: () {
        Dialogs.materialDialog(
          color: AdaptiveTheme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color.fromARGB(255, 21, 21, 21),
          context: context,
          title: 'Theme',
          titleAlign: TextAlign.left,
          titleStyle: AdaptiveTheme.of(context).theme.textTheme.displayMedium!,
          customViewPosition: CustomViewPosition.BEFORE_ACTION,
          customView: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 75,
                childAspectRatio: 1.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                mainAxisExtent: 50,
              ),
              itemCount: 7,
              itemBuilder: (context, index) {
                List<Color> colorSchemes = [
                  Colors.red,
                  Colors.orange,
                  Colors.yellow,
                  Colors.green,
                  Colors.blue,
                  Colors.indigo,
                  Colors.purple,
                ];

                return ColorSchemeButton(
                  color: colorSchemes[index],
                  isSelected: Provider.of<ThemeProvider>(context, listen: false)
                          .preferredColor
                          .value ==
                      colorSchemes[index].value,
                  onSelect: () {
                    Provider.of<ThemeProvider>(context, listen: false)
                        .updateColor(colorSchemes[index], context);
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
    );
  }

  SettingsItem buildThemeModeSettings(BuildContext context) {
    return SettingsItem(
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
    );
  }

  Widget buildAccountSettings(BuildContext context) {
    return SettingsGroup(
      settingsGroupTitle: "Account",
      items: [
        buildSignOutItem(context),
      ],
    );
  }

  SettingsItem buildSignOutItem(BuildContext context) {
    return SettingsItem(
      onTap: () async {
        Dialogs.materialDialog(
          context: context,
          title: 'Logout',
          msg: 'Are you sure you want to logout?',
          color: AdaptiveTheme.of(context).brightness == Brightness.light
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
              textStyle:
                  AdaptiveTheme.of(context).brightness == Brightness.light
                      ? const TextStyle(color: Color.fromARGB(255, 21, 21, 21))
                      : const TextStyle(color: Colors.white),
              iconColor:
                  AdaptiveTheme.of(context).brightness == Brightness.light
                      ? const Color.fromARGB(255, 21, 21, 21)
                      : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color:
                      AdaptiveTheme.of(context).brightness == Brightness.light
                          ? const Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                ),
              ),
            ),
            IconsButton(
              onPressed: () async {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoadingScreen(
                      futures: [
                        DatabaseHelper().auth.signOut(),
                        Future.delayed(5.seconds)
                      ],
                      onDone: (context, _) => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountSetup(
                            Login(),
                          ),
                        ),
                      ),
                    ),
                  ),
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
        iconsColor: AdaptiveTheme.of(context).brightness == Brightness.light
            ? Colors.red
            : Colors.white,
        withBackground: false,
      ),
    );
  }
}
