import 'package:codecraft/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SidebarItem {
  final IconData icon;
  final String label;
  final Widget screen;
  final List<SidebarItem>? subItems;

  SidebarItem({
    required this.icon,
    required this.label,
    required this.screen,
    this.subItems,
  });
}

class PaginatedDrawer extends ConsumerStatefulWidget {
  final List<SidebarItem> items;
  final Widget? header;

  const PaginatedDrawer({super.key, required this.items, this.header});

  @override
  ConsumerState<PaginatedDrawer> createState() => _PaginatedDrawerState();
}

class _PaginatedDrawerState extends ConsumerState<PaginatedDrawer> {
  final PageController _pageController = PageController();
  final List<List<SidebarItem>> _pages = [];
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pages.add(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          if (widget.header != null) widget.header!,
          if (_currentPageIndex > 0)
            ListTile(
              leading: const Icon(Icons.arrow_back),
              title: const Text('Back'),
              onTap: _goBack,
            ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _buildDrawerPage(_pages[index]);
              },
              physics: const NeverScrollableScrollPhysics(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerPage(List<SidebarItem> items) {
    return ListView(
      children: items.map((item) => _buildDrawerItem(item)).toList(),
    );
  }

  Widget _buildDrawerItem(SidebarItem item) {
    return ListTile(
      leading: Icon(item.icon),
      title: Text(item.label),
      onTap: () {
        if (item.subItems != null && item.subItems!.isNotEmpty) {
          _goToSubPage(item.subItems!);
        } else {
          ref.read(screenProvider.notifier).pushScreen(item.screen);
          Navigator.pop(context);
        }
      },
      trailing: item.subItems != null && item.subItems!.isNotEmpty
          ? const Icon(Icons.chevron_right)
          : null,
    );
  }

  void _goToSubPage(List<SidebarItem> subItems) {
    setState(() {
      _currentPageIndex++;
      _pages.add(subItems);
    });
    _pageController.animateToPage(
      _currentPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _goBack() {
    setState(() {
      _currentPageIndex--;
      _pages.removeLast();
    });
    _pageController.animateToPage(
      _currentPageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
