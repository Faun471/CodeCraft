import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/screens/account_setup/account_setup.dart';
import 'package:codecraft/screens/account_setup/login.dart';
import 'package:codecraft/screens/mentor/modules.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/screens/settings/settings.dart';
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

    if (DatabaseHelper().auth.currentUser == null) {
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AccountSetup(Login())));
    }

    currentUser = DatabaseHelper().auth.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    isVertical = MediaQuery.of(context).size.aspectRatio < 1.0;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
            ),
            const SizedBox(width: 10),
            const AutoSizeText('CODECRAFT', minFontSize: 36),
            Expanded(
              child: SizedBox(),
            ),
            AutoSizeText(
              currentUser.displayName ?? currentUser.email!,
              minFontSize: 24,
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
      drawer: isVertical
          ? SidebarX(
              controller: sidebarXController,
              showToggleButton: false,
              theme: SidebarXTheme(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      AdaptiveTheme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Color.fromARGB(255, 21, 21, 21),
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: TextStyle(
                  color:
                      AdaptiveTheme.of(context).brightness == Brightness.light
                          ? Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                ),
                selectedTextStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context).preferredColor),
                itemTextPadding: const EdgeInsets.only(left: 30),
                selectedItemTextPadding: const EdgeInsets.only(left: 30),
                iconTheme: IconThemeData(
                  color:
                      AdaptiveTheme.of(context).brightness == Brightness.light
                          ? Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                  size: 20,
                ),
              ),
              extendedTheme: SidebarXTheme(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                    color:
                        AdaptiveTheme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Color.fromARGB(255, 21, 21, 21)),
                margin: EdgeInsets.only(right: 10),
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
              items: [
                SidebarXItem(
                  icon: Icons.home,
                  label: 'Home',
                ),
                SidebarXItem(
                  icon: Icons.settings,
                  label: 'Settings',
                ),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!isVertical)
            SidebarX(
              controller: sidebarXController,
              showToggleButton: false,
              theme: SidebarXTheme(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      AdaptiveTheme.of(context).brightness == Brightness.light
                          ? Colors.white
                          : Color.fromARGB(255, 21, 21, 21),
                  borderRadius: BorderRadius.circular(20),
                ),
                textStyle: TextStyle(
                  color:
                      AdaptiveTheme.of(context).brightness == Brightness.light
                          ? Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                ),
                selectedTextStyle: TextStyle(
                    color: Provider.of<ThemeProvider>(context).preferredColor),
                itemTextPadding: const EdgeInsets.only(left: 30),
                selectedItemTextPadding: const EdgeInsets.only(left: 30),
                iconTheme: IconThemeData(
                  color:
                      AdaptiveTheme.of(context).brightness == Brightness.light
                          ? Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                  size: 20,
                ),
              ),
              extendedTheme: SidebarXTheme(
                width: MediaQuery.of(context).size.width * 0.2,
                decoration: BoxDecoration(
                    color:
                        AdaptiveTheme.of(context).brightness == Brightness.light
                            ? Colors.white
                            : Color.fromARGB(255, 28, 27, 31)),
                margin: EdgeInsets.only(right: 10),
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
              items: [
                SidebarXItem(
                  icon: Icons.home,
                  label: 'Home',
                ),
                SidebarXItem(
                  icon: Icons.settings,
                  label: 'Settings',
                ),
              ],
            ),
          Expanded(
            child: switch (sidebarXController.selectedIndex) {
              0 => Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            if (!isCompleted) {
                              return;
                            }

                            setState(() {
                              isCompleted = false;
                            });
                          },
                          child: Text(
                            'Modules',
                            style: TextStyle(
                              decoration: isCompleted
                                  ? TextDecoration.none
                                  : TextDecoration.underline,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            if (isCompleted) {
                              return;
                            }
                            setState(() {
                              isCompleted = true;
                            });
                          },
                          child: Text(
                            'Completed',
                            style: TextStyle(
                              decoration: isCompleted
                                  ? TextDecoration.underline
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Modules(
                        isCompleted: isCompleted,
                      ),
                    ),
                  ],
                ),
              1 => Settings(),
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
}
