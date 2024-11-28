import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/settings/settings.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/notification_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarItem {
  final IconData icon;
  final String label;
  final Widget screen;
  final List<SidebarItem>? subItems;
  final Function()? onTap;
  SidebarItem? parent;

  SidebarItem({
    required this.icon,
    required this.label,
    required this.screen,
    this.subItems,
    this.onTap,
    this.parent,
  });

  SidebarItem copyWith({List<SidebarItem>? subItems, SidebarItem? parent}) {
    return SidebarItem(
      icon: icon,
      label: label,
      screen: screen,
      subItems: subItems ?? this.subItems,
      onTap: onTap,
      parent: parent ?? this.parent,
    );
  }
}

class Body extends ConsumerStatefulWidget {
  final List<SidebarItem> sidebarItems;

  const Body({super.key, required this.sidebarItems});

  @override
  BodyState createState() => BodyState();
}

class BodyState extends ConsumerState<Body> {
  bool isSmallScreen = false;
  late List<SidebarItem> _flattenedItems;

  @override
  void initState() {
    super.initState();
    _flattenedItems = _flattenSidebarItems(widget.sidebarItems);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .watch(screenProvider.notifier)
          .replaceScreen(_flattenedItems.first.screen);

      final isFirstLogin =
          ref.read(appUserNotifierProvider).requireValue.isFirstLogin;

      if (isFirstLogin) {
        Utils.displayDialog(
            context: context,
            lottieAsset: 'assets/anim/welcome.json',
            title: 'Welcome to CodeCraft',
            content:
                'We are excited to have you here. We hope you enjoy your learning experience with us.',
            isDismissible: false,
            onDismiss: () async {
              await ref.read(appUserNotifierProvider.notifier).updateData({
                'isFirstLogin': false,
              });
            });
      }
    });
  }

  List<SidebarItem> _flattenSidebarItems(List<SidebarItem> items,
      [SidebarItem? parent]) {
    return items.expand((item) {
      final newItem = item.copyWith(parent: parent);
      if (item.subItems != null && item.subItems!.isNotEmpty) {
        return [newItem, ..._flattenSidebarItems(item.subItems!, newItem)];
      }
      return [newItem];
    }).toList();
  }

  void _onItemTap(SidebarItem item) {
    if (item.onTap != null) {
      item.onTap!();
      return;
    }

    // Navigate to the selected item's screen
    ref.read(screenProvider.notifier).pushScreen(item.screen);

    // If the selected item has a parent, also update the screen for the parent
    SidebarItem? currentItem = item.parent;
    while (currentItem != null) {
      if (currentItem.screen.runtimeType !=
          ref.read(screenProvider).screenStack.last.runtimeType) {
        ref.read(screenProvider.notifier).pushScreen(currentItem.screen);
        break;
      }
      currentItem = currentItem.parent;
    }

    // Close the drawer on small screens
    if (isSmallScreen) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    isSmallScreen = MediaQuery.of(context).size.width < 768;
    final appUser = ref.read(appUserNotifierProvider).requireValue;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (ref.watch(screenProvider).screenStack.length > 1) {
          ref.watch(screenProvider.notifier).popScreen();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Image.asset(
                'assets/images/ccOrangeLogo.png',
                fit: BoxFit.fitHeight,
                width: 35,
                height: 35,
              ),
              AutoSizeText(
                'CodeCraft',
                minFontSize: 24,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeUtils.getTextColorForBackground(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          leading: isSmallScreen
              ? Builder(
                  builder: (BuildContext context) {
                    return IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );
                  },
                )
              : null,
          actions: [
            if (appUser.accountType == 'mentor') ...[
              Padding(
                padding: EdgeInsets.only(right: 20),
                child: NotificationButton(userId: appUser.id!),
              ),
            ]
          ],
        ),
        drawer: isSmallScreen ? _buildSidebar(appUser) : null,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSmallScreen) _buildSidebar(appUser),
            const SizedBox(width: 8),
            Expanded(
              child: ref.watch(screenProvider).screenStack.last,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(AppUser appUser) {
    return Drawer(
      width: MediaQuery.of(context).size.width > 768 ? 250 : null,
      shadowColor: Colors.black,
      elevation: 24,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildSidebarHeader(appUser),
          ..._buildSidebarItems(widget.sidebarItems),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(AppUser appUser) {
    return DrawerHeader(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: CachedNetworkImageProvider(
              appUser.photoUrl == null ||
                      ref
                          .read(appUserNotifierProvider)
                          .requireValue
                          .photoUrl!
                          .isEmpty
                  ? FirebaseAuth.instance.currentUser!.photoURL ??
                      'https://api.dicebear.com/9.x/thumbs/png?seed=${FirebaseAuth.instance.currentUser!.uid}'
                  : ref.read(appUserNotifierProvider).requireValue.photoUrl!,
            ),
          ),
          const SizedBox(height: 10),
          AutoSizeText(
            appUser.displayName ??
                FirebaseAuth.instance.currentUser!.displayName ??
                '${appUser.firstName!} ${appUser.lastName!}',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSidebarItems(List<SidebarItem> items) {
    return items.map((item) {
      if (item.subItems != null && item.subItems!.isNotEmpty) {
        return ExpansionTile(
          leading: Icon(item.icon),
          title: Text(item.label),
          children: _buildSidebarItems(item.subItems!),
        );
      } else {
        return Stack(
          children: [
            ListTile(
              leading: Icon(item.icon),
              title: Text(item.label),
              onTap: () => _onItemTap(item),
              selected: _isItemSelected(item),
            ),
            if (_isItemSelected(item))
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(2),
                      bottomRight: Radius.circular(2),
                    ),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
          ],
        );
      }
    }).toList();
  }

  bool _isItemSelected(SidebarItem item) {
    final currentScreenType =
        ref.watch(screenProvider).screenStack.last.runtimeType;

    if (currentScreenType == SettingsScreen) {
      SettingsScreen currentSettingsScreen =
          ref.watch(screenProvider).screenStack.last as SettingsScreen;

      return currentSettingsScreen.initialTab == item.label;
    }

    return currentScreenType == item.screen.runtimeType;
  }
}
