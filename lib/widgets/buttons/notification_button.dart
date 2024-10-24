import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:popup_menu_plus/popup_menu_plus.dart';

class NotificationButton extends ConsumerStatefulWidget {
  final String userId;

  const NotificationButton({super.key, required this.userId});

  @override
  _NotificationButtonState createState() => _NotificationButtonState();
}

class _NotificationButtonState extends ConsumerState<NotificationButton> {
  GlobalKey btnKey = GlobalKey();
  late PopupMenu _menu;

  @override
  Widget build(BuildContext context) {
    final joinRequestsStream = ref
        .watch(invitationServiceProvider.notifier)
        .getJoinRequestsStream(widget.userId);

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: joinRequestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final joinRequests = snapshot.data ?? [];
        final requestCount = joinRequests.length;

        return Stack(
          children: [
            IconButton(
              key: btnKey,
              icon: Icon(
                Icons.notifications,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.white
                    : Colors.black45,
              ),
              onPressed: () => _showNotificationMenu(context, joinRequests),
            ),
            if (requestCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    '$requestCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showNotificationMenu(
    BuildContext context,
    List<Map<String, dynamic>> joinRequests,
  ) {
    _menu = PopupMenu(
      context: context,
      config: MenuConfig(
        backgroundColor: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        type: MenuType.custom,
        itemHeight: MediaQuery.of(context).size.height * 0.15,
        itemWidth: 300,
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          maxWidth: 300,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (joinRequests.isEmpty)
                Center(
                  child: const ListTile(
                    title: Text('No pending requests'),
                  ),
                ),
              for (var request in joinRequests)
                _buildRequestItem(context, request),
            ],
          ),
        ),
      ),
    );

    _menu.show(widgetKey: btnKey);
  }

  Widget _buildRequestItem(BuildContext context, Map<String, dynamic> request) {
    return FutureBuilder(
      future: DatabaseHelper().users.doc(request['apprenticeId']).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const ListTile(title: Text('Loading...'));
        }
        final userData = snapshot.data!.data()! as Map<String, dynamic>;
        return ListTile(
          title: Text('${userData['firstName']} ${userData['lastName']}'),
          subtitle: const Text('Wants to join'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check, color: Colors.green),
                onPressed: () =>
                    _handleRequestAction(context, request, 'accepted'),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () =>
                    _handleRequestAction(context, request, 'rejected'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleRequestAction(
      BuildContext context, Map<String, dynamic> request, String status) {
    ref.read(invitationServiceProvider.notifier).updateJoinRequestStatus(
          request['code'],
          request['apprenticeId'],
          status,
        );
    if (_menu.isShow) {
      _menu.dismiss();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request ${status.capitalize()}')),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
