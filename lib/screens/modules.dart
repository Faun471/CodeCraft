import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/page.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/screens/module.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:codecraft/themes/theme_utils.dart';
import 'package:codecraft/widgets/custom_list_view.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:sidebarx/sidebarx.dart';

class Modules extends StatefulWidget {
  const Modules({super.key});

  @override
  ModulesState createState() => ModulesState();
}

class ModulesState extends State<Modules> {
  @override
  void initState() {
    super.initState();
    AppUser();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ThemeProvider>(context, listen: false)
          .loadColorFromFirestore()
          .then((_) {
        var preferredColor =
            Provider.of<ThemeProvider>(context, listen: false).preferredColor;

        setState(() {
          AdaptiveTheme.of(context).setTheme(
            light: ThemeUtils.changeThemeColor(
              AdaptiveTheme.of(context).lightTheme,
              preferredColor,
            ),
            dark: ThemeUtils.changeThemeColor(
              AdaptiveTheme.of(context).darkTheme,
              preferredColor,
            ),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SidebarX(
        controller: SidebarXController(selectedIndex: 0, extended: true),
        showToggleButton: false,
        extendedTheme: SidebarXTheme(
          width: 200,
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
            Image.asset(
              'assets/images/flutter.png',
              width: 100,
              height: 100,
            ),
            const AutoSizeText(
              'CodeCraft',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
          ],
        ),
        items: [
          const SidebarXItem(icon: Icons.book_rounded, label: 'Modules'),
          SidebarXItem(
            icon: Icons.hourglass_empty_rounded,
            label: 'Coming soon...',
            onTap: () {
              Dialogs.materialDialog(
                context: context,
                msg: 'More features coming soon!',
                title: 'Coming soon...',
                lottieBuilder: Lottie.asset(
                  'assets/anim/soon.json',
                  repeat: true,
                  fit: BoxFit.contain,
                  height: 200,
                  width: 200,
                ),
                msgStyle:
                    AdaptiveTheme.of(context).theme.textTheme.displaySmall!,
                titleStyle:
                    AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
                color: AdaptiveTheme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color.fromARGB(255, 21, 21, 21),
                actions: [
                  Builder(
                    builder: (dialogContext) => IconsButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      text: 'Close',
                      iconData: Icons.close,
                      textStyle: const TextStyle(color: Colors.grey),
                      iconColor: AdaptiveTheme.of(context).brightness ==
                              Brightness.light
                          ? const Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 21, 21, 21),
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          SidebarXItem(
            icon: Icons.hourglass_empty_rounded,
            label: 'Coming soon...',
            onTap: () {
              Dialogs.materialDialog(
                context: context,
                msg: 'More features coming soon!',
                title: 'Coming soon...',
                lottieBuilder: Lottie.asset(
                  'assets/anim/soon.json',
                  repeat: true,
                  fit: BoxFit.contain,
                  height: 200,
                  width: 200,
                ),
                msgStyle:
                    AdaptiveTheme.of(context).theme.textTheme.displaySmall!,
                titleStyle:
                    AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
                color: AdaptiveTheme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color.fromARGB(255, 21, 21, 21),
                actions: [
                  Builder(
                    builder: (dialogContext) => IconsButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      text: 'Close',
                      iconData: Icons.close,
                      textStyle: const TextStyle(color: Colors.grey),
                      iconColor: AdaptiveTheme.of(context).brightness ==
                              Brightness.light
                          ? const Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 21, 21, 21),
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          SidebarXItem(
            icon: Icons.hourglass_empty_rounded,
            label: 'Coming soon...',
            onTap: () {
              Dialogs.materialDialog(
                context: context,
                msg: 'More features coming soon!',
                title: 'Coming soon...',
                lottieBuilder: Lottie.asset(
                  'assets/anim/soon.json',
                  repeat: true,
                  fit: BoxFit.contain,
                  height: 200,
                  width: 200,
                ),
                msgStyle:
                    AdaptiveTheme.of(context).theme.textTheme.displaySmall!,
                titleStyle:
                    AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
                color: AdaptiveTheme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color.fromARGB(255, 21, 21, 21),
                actions: [
                  Builder(
                    builder: (dialogContext) => IconsButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      text: 'Close',
                      iconData: Icons.close,
                      textStyle: const TextStyle(color: Colors.grey),
                      iconColor: AdaptiveTheme.of(context).brightness ==
                              Brightness.light
                          ? const Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 21, 21, 21),
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          SidebarXItem(
            icon: Icons.hourglass_empty_rounded,
            label: 'Coming soon...',
            onTap: () {
              Dialogs.materialDialog(
                context: context,
                msg: 'More features coming soon!',
                title: 'Coming soon...',
                lottieBuilder: Lottie.asset(
                  'assets/anim/soon.json',
                  repeat: true,
                  fit: BoxFit.contain,
                  height: 200,
                  width: 200,
                ),
                msgStyle:
                    AdaptiveTheme.of(context).theme.textTheme.displaySmall!,
                titleStyle:
                    AdaptiveTheme.of(context).theme.textTheme.displayLarge!,
                color: AdaptiveTheme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : const Color.fromARGB(255, 21, 21, 21),
                actions: [
                  Builder(
                    builder: (dialogContext) => IconsButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      text: 'Close',
                      iconData: Icons.close,
                      textStyle: const TextStyle(color: Colors.grey),
                      iconColor: AdaptiveTheme.of(context).brightness ==
                              Brightness.light
                          ? const Color.fromARGB(255, 21, 21, 21)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: AdaptiveTheme.of(context).mode.isDark
                              ? Colors.white
                              : const Color.fromARGB(255, 21, 21, 21),
                        ),
                      ),
                    ),
                  )
                ],
              );
            },
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
      appBar: AppBar(
        title: const Text('Modules'),
      ),
      body: FutureBuilder<List<CustomPage>>(
        future: CustomPage.loadPagesFromYamlDirectory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.black,
                size: 200,
              ),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return CustomListItem(
                title: snapshot.data![index].title,
                description: snapshot.data![index].description,
                unlockLevel: snapshot.data![index].level,
                imageUrl: snapshot.data![index].image,
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Module(
                        markdown:
                            'assets/pages/${snapshot.data![index].markdownName}.md',
                        quizName:
                            'assets/quizzes/${snapshot.data![index].quizName}.yaml',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
