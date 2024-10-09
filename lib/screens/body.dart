import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/providers/screen_provider.dart';
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
  SidebarItem? selectedItem;
  late List<SidebarItem> _flattenedItems;

  @override
  void initState() {
    super.initState();
    _flattenedItems = _flattenSidebarItems(widget.sidebarItems);
    selectedItem = _flattenedItems.first;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(screenProvider.notifier).replaceScreen(selectedItem!.screen);
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
    setState(() {
      selectedItem = item;
    });

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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (ref.read(screenProvider).screenStack.length > 1) {
          ref.read(screenProvider.notifier).popScreen();
          setState(() {
            selectedItem = _findSelectedItem();
          });
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
                  color: Theme.of(context).primaryColor.computeLuminance() > 0.5
                      ? Colors.black
                      : Colors.white,
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
        ),
        drawer: isSmallScreen ? _buildSidebar() : null,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isSmallScreen) _buildSidebar(),
            const SizedBox(width: 8),
            Expanded(
              child: ref.watch(screenProvider).screenStack.last,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Drawer(
      width: MediaQuery.of(context).size.width > 768 ? 250 : null,
      shadowColor: Colors.black,
      elevation: 24,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _buildSidebarHeader(),
          ..._buildSidebarItems(widget.sidebarItems),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return DrawerHeader(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: CachedNetworkImageProvider(
              ref.read(appUserNotifierProvider).requireValue.photoUrl == null ||
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
            ref.read(appUserNotifierProvider).value!.displayName ?? '',
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
        return ListTile(
          leading: Icon(item.icon),
          title: Text(item.label),
          onTap: () => _onItemTap(item),
          selected: _isItemSelected(item),
        );
      }
    }).toList();
  }

  bool _isItemSelected(SidebarItem item) {
    return selectedItem == item || (selectedItem?.parent == item);
  }

  SidebarItem? _findSelectedItem() {
    final currentScreenType =
        ref.read(screenProvider).screenStack.last.runtimeType;
    return _flattenedItems.firstWhere(
      (item) => item.screen.runtimeType == currentScreenType,
      orElse: () => _flattenedItems.first,
    );
  }
}
