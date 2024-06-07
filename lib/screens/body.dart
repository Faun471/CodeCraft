import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sidebarx/sidebarx.dart';

class SidebarItem {
  final IconData icon;
  final String label;
  final Widget screen;

  SidebarItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}

class FoldableSidebarItem extends SidebarItem {
  final List<SidebarItem> subItems;

  FoldableSidebarItem({
    required super.icon,
    required super.label,
    required super.screen,
    required this.subItems,
  });
}

class Body extends ConsumerStatefulWidget {
  final List<SidebarItem> sidebarItems;

  const Body({super.key, required this.sidebarItems});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends ConsumerState<Body> {
  late bool isVertical;
  bool isCompleted = false;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref
          .watch(screenProvider.notifier)
          .replaceScreen(widget.sidebarItems.first.screen);
    });
  }

  @override
  Widget build(BuildContext context) {
    isVertical = MediaQuery.of(context).size.aspectRatio < 1.0;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (ref.read(screenProvider).screenStack.length > 1) {
          ref.read(screenProvider.notifier).popScreen();

          selectedIndex = widget.sidebarItems
              .indexOf(widget.sidebarItems.firstWhere((element) {
            return element.screen.runtimeType ==
                ref.read(screenProvider).screenStack.last.runtimeType;
          }));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              if (ref.watch(screenProvider).screenStack.length > 1)
                // if (!isVertical)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    ref.read(screenProvider.notifier).popScreen();
                    selectedIndex = widget.sidebarItems
                        .indexOf(widget.sidebarItems.firstWhere((element) {
                      return element.screen.runtimeType ==
                          ref.read(screenProvider).screenStack.last.runtimeType;
                    }));
                  },
                ),
              const SizedBox(
                width: 10,
              ),
              ImageFiltered(
                imageFilter: ColorFilter.mode(
                  Theme.of(context).primaryColor,
                  BlendMode.srcIn,
                ),
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
                '${ref.watch(appUserNotifierProvider).value!.displayName ?? 'User'} ',
                presetFontSizes: const [12, 16, 18, 24],
                textAlign: TextAlign.end,
              ),
              const SizedBox(width: 10),
              ClipOval(
                child: CachedNetworkImage(
                  imageUrl: ref
                          .watch(appUserNotifierProvider)
                          .value!
                          .data['photoURL'] ??
                      'https://cdn.icon-icons.com/icons2/1378/PNG/512/avatardefault_92824.png',
                  height: 30,
                  width: 30,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ],
          ),
        ),
        drawer: isVertical ? _buildSidebar(context, extended: true) : null,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isVertical) _buildSidebar(context),
            Expanded(child: ref.watch(screenProvider).screenStack.last),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, {bool extended = false}) {
    return SidebarX(
      controller: SidebarXController(
        selectedIndex: selectedIndex,
        extended: true,
      ),
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
          color: Theme.of(context).primaryColor,
        ),
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
      items: widget.sidebarItems.map((item) {
        if (item is FoldableSidebarItem) {
          return SidebarXItem(
              icon: item.icon,
              label: item.label,
              onTap: () {},
              iconBuilder: (isSelected, isHovered) {
                return ExpansionTile(
                  title: Text(item.label),
                  children: item.subItems.map((subItem) {
                    return ListTile(
                      leading: Icon(subItem.icon),
                      title: Text(subItem.label),
                      onTap: () {
                        setState(() {
                          selectedIndex = widget.sidebarItems.indexOf(subItem);
                        });
                      },
                    );
                  }).toList(),
                );
              });
        } else {
          return SidebarXItem(
            icon: item.icon,
            label: item.label,
            onTap: () {
              if (item.screen.runtimeType ==
                  ref.read(screenProvider).screenStack.last.runtimeType) {
                return;
              }

              selectedIndex = widget.sidebarItems.indexOf(item);
              ref.watch(screenProvider.notifier).pushScreen(item.screen);
            },
          );
        }
      }).toList(),
    );
  }
}
