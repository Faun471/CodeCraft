import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/screens/modules.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  final User currentUser = DatabaseHelper().auth.currentUser!;
  late SidebarXController sidebarXController;

  @override
  void initState() {
    super.initState();

    sidebarXController = SidebarXController(
      selectedIndex: 0,
      extended: true,
    )..addListener(() {
        setState(() {});
      });

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        final ThemeProvider themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);

        await themeProvider.loadColorFromFirestore().then(
          (value) {
            if (value == themeProvider.preferredColor) {
              return;
            }

            themeProvider.updateColor(value, context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: sidebarXController.selectedIndex == 0
            ? const Text('Modules')
            : sidebarXController.selectedIndex == 1
                ? const Text('Coding Challenges')
                : const Text('Leaderboard'),
      ),
      drawer: SidebarX(
        controller: sidebarXController,
        showToggleButton: false,
        extendedTheme: SidebarXTheme(
          width: MediaQuery.sizeOf(context).width * 0.6,
          decoration: BoxDecoration(
              color: AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )),
          textStyle: AdaptiveTheme.of(context).theme.textTheme.bodyLarge,
          itemTextPadding: const EdgeInsets.only(left: 30),
          selectedItemTextPadding: const EdgeInsets.only(left: 30),
          itemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
            ),
          ),
          selectedItemDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
            ),
          ),
          selectedIconTheme: IconThemeData(
            color: AdaptiveTheme.of(context).theme.primaryColor,
          ),
          selectedTextStyle:
              AdaptiveTheme.of(context).theme.textTheme.bodyLarge,
        ),
        headerBuilder: (context, extended) => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: 40 + MediaQuery.of(context).padding.top),
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Provider.of<ThemeProvider>(context).preferredColor,
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: DatabaseHelper().auth.currentUser!.photoURL ?? '',
                  placeholder: (context, url) =>
                      LoadingAnimationWidget.halfTriangleDot(
                    color:
                        AdaptiveTheme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : const Color.fromARGB(255, 21, 21, 21),
                    size: 100,
                  ),
                  errorWidget: (context, url, error) =>
                      Image.asset('assets/images/logo.png'),
                  fit: BoxFit.cover,
                  useOldImageOnUrlChange: true,
                ),
              ),
            ),
            AutoSizeText(
              DatabaseHelper().auth.currentUser!.displayName ?? 'User',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
        items: const [
          SidebarXItem(
            icon: Icons.book_rounded,
            label: 'Modules',
          ),
          SidebarXItem(
            icon: Icons.code_rounded,
            label: 'Coding Challenges',
          ),
          SidebarXItem(
            icon: Icons.leaderboard_rounded,
            label: 'Leaderboard',
          ),
        ],
        headerDivider: Divider(
          color: AdaptiveTheme.of(context).brightness == Brightness.light
              ? Colors.grey
              : Colors.white,
        ),
        footerDivider: Divider(
          color: AdaptiveTheme.of(context).brightness == Brightness.light
              ? Colors.grey
              : Colors.white,
        ),
        footerBuilder: (context, extended) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconsButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const Settings();
                  },
                ));
              },
              text: 'Settings',
              textStyle: AdaptiveTheme.of(context).theme.textTheme.bodyLarge,
              iconData: Icons.settings_rounded,
            ),
          ],
        ),
      ),
      body: switch (sidebarXController.selectedIndex) {
        0 => const Modules(),
        _ => const Center(
            child: AutoSizeText(
              'Coming soon...',
              minFontSize: 24,
              maxFontSize: 48,
            ),
          )
      },
    );
  }
}
