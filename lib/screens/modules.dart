import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/page.dart';
import 'package:codecraft/screens/login.dart';
import 'package:codecraft/screens/module.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:codecraft/widgets/custom_list_view.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:sidebarx/sidebarx.dart';

class Modules extends StatelessWidget {
  Modules({super.key}) {
    AppUser();
  }

  @override
  Widget build(BuildContext context) {
    SidebarXController controller =
        SidebarXController(selectedIndex: 0, extended: true);
    controller.addListener(() {
      if (controller.selectedIndex != 0) {
        controller.selectIndex(0);
      }
    });

    return Scaffold(
      drawer: SidebarX(
        controller: controller,
        showToggleButton: false,
        extendedTheme: SidebarXTheme(
          width: 200,
          decoration: BoxDecoration(
              color: AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )),
          hoverColor: AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
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
            color: AdaptiveTheme.of(context).theme.scaffoldBackgroundColor,
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
          const SidebarXItem(iconWidget: SizedBox(height: 20)),
          const SidebarXItem(icon: Icons.book_rounded, label: 'Modules'),
          SidebarXItem(
            icon: Icons.hourglass_empty_rounded,
            label: 'Coming soon...',
            onTap: () {
              controller.selectIndex(0);
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
                msgStyle: AdaptiveTheme.of(context).mode.isLight
                    ? const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Color.fromARGB(255, 21, 21, 21),
                      )
                    : const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                titleStyle: AdaptiveTheme.of(context).mode.isLight
                    ? const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 21, 21, 21),
                      )
                    : const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                color: AdaptiveTheme.of(context).mode.isLight
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
                      iconColor: AdaptiveTheme.of(context).mode.isLight
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
        footerItems: [
          SidebarXItem(
            icon: Icons.settings_rounded,
            label: 'Settings',
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return const Settings();
              },
            )),
          ),
        ],
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
                color: Colors.white,
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
