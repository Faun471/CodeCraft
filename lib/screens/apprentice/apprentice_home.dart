import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/screens/apprentice/modules.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  late User currentUser;
  late SidebarXController sidebarXController;
  late bool isVertical;
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();

    sidebarXController = SidebarXController(
      selectedIndex: 0,
      extended: true,
    )..addListener(() {
        setState(() {});
      });

    currentUser = DatabaseHelper().auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    isVertical = MediaQuery.of(context).size.aspectRatio < 1.0;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ImageFiltered(
              imageFilter: ColorFilter.mode(
                  Provider.of<ThemeProvider>(context).preferredColor,
                  BlendMode.srcIn),
              child: Image.asset(
                'assets/images/logo.png',
                height: 30,
              ),
            ),
            const SizedBox(width: 10),
            const AutoSizeText(
              'CODECRAFT',
              minFontSize: 36,
            ),
            const Expanded(
              child: SizedBox(),
            ),
            AutoSizeText(
              currentUser.displayName ?? currentUser.email!,
              presetFontSizes: const [12, 16, 18, 24],
              textAlign: TextAlign.end,
            ),
            const SizedBox(width: 10),
            ClipOval(
                child: CachedNetworkImage(
              imageUrl: currentUser.photoURL ?? '',
              height: 30,
              width: 30,
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ))
          ],
        ),
      ),
      drawer: isVertical ? _buildSidebar(context, extended: true) : null,
      body: Row(
        children: [
          if (!isVertical) _buildSidebar(context),
          Expanded(
            child: switch (sidebarXController.selectedIndex) {
              0 => const Column(
                  children: [
                    Expanded(
                      child: Modules(),
                    ),
                  ],
                ),
              1 => const Settings(),
              _ => const Center(
                  child: AutoSizeText(
                    'Coming soon...',
                    minFontSize: 24,
                    maxFontSize: 48,
                  ),
                )
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {bool extended = false}) {
    return SidebarX(
      controller: sidebarXController,
      showToggleButton: false,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AdaptiveTheme.of(context).brightness == Brightness.light
              ? Colors.white
              : const Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.circular(20),
        ),
        textStyle: TextStyle(
          color: AdaptiveTheme.of(context).brightness == Brightness.light
              ? const Color.fromARGB(255, 21, 21, 21)
              : Colors.white,
        ),
        selectedTextStyle: TextStyle(
            color: Provider.of<ThemeProvider>(context).preferredColor),
        itemTextPadding: const EdgeInsets.only(left: 30),
        selectedItemTextPadding: const EdgeInsets.only(left: 30),
        iconTheme: IconThemeData(
          color: AdaptiveTheme.of(context).brightness == Brightness.light
              ? const Color.fromARGB(255, 21, 21, 21)
              : Colors.white,
          size: 20,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: extended
            ? MediaQuery.of(context).size.width * 0.9
            : MediaQuery.of(context).size.width * 0.2,
        decoration: BoxDecoration(
            color: AdaptiveTheme.of(context).brightness == Brightness.light
                ? Colors.white
                : const Color.fromARGB(255, 21, 21, 21)),
        margin: const EdgeInsets.only(right: 10),
      ),
      headerBuilder: (context, extended) {
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Image.asset('assets/images/logo.png'),
          ),
        );
      },
      items: const [
        SidebarXItem(
          icon: Icons.home,
          label: 'Home',
        ),
        SidebarXItem(
          icon: Icons.settings,
          label: 'Settings',
        ),
        SidebarXItem(
          icon: Icons.code_rounded,
          label: 'Coding Challenges',
        ),
      ],
    );
  }
}
