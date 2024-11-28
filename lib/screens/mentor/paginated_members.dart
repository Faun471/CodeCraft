import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMembersProvider = StateProvider<List<AppUser>>((ref) => []);
final currentPageProvider = StateProvider<int>((ref) => 0);
final visibleMembersProvider = StateProvider<List<AppUser>>((ref) => []);

class PaginatedMembersList extends ConsumerStatefulWidget {
  final List<AppUser> members;
  final int itemsPerPage;
  final String title;
  final Color backgroundColor;
  final bool showCheckbox;
  final VoidCallback? onSelected;

  const PaginatedMembersList({
    super.key,
    required this.members,
    required this.backgroundColor,
    this.title = 'display name',
    this.itemsPerPage = 7,
    this.showCheckbox = false,
    this.onSelected,
  });

  @override
  _PaginatedMembersListState createState() => _PaginatedMembersListState();
}

class _PaginatedMembersListState extends ConsumerState<PaginatedMembersList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 1), () {
        _updateVisibleMembers();
      });
    });
  }

  void _updateVisibleMembers() {
    final paginatedMembers = _getPaginatedMembers();
    ref.watch(visibleMembersProvider.notifier).update(
          (visibleMembers) => paginatedMembers,
        );
  }

  @override
  Widget build(BuildContext context) {
    final selectedMembers = ref.watch(selectedMembersProvider.notifier).state;
    if (widget.members.isEmpty) {
      return Center(
        child: Text(
          'No members available.',
          style: TextStyle(
            color: ThemeUtils.getTextColorForBackground(widget.backgroundColor),
          ),
        ),
      );
    }

    final paginatedMembers = _getPaginatedMembers();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: paginatedMembers.length > _getRemainingItems()
                ? _getRemainingItems()
                : paginatedMembers.length,
            itemBuilder: (context, index) {
              final user = paginatedMembers[index];

              String title = '';

              switch (widget.title.toLowerCase()) {
                case 'display name':
                  title =
                      user.displayName ?? '${user.firstName} ${user.lastName}';
                  break;
                case 'first name':
                  title = user.firstName!;
                  break;
                case 'last name':
                  title = user.lastName!;
                  break;
                case 'email':
                  title = user.email!;
                  break;
                case 'full name':
                  title = '${user.firstName!} ${user.lastName!}';
              }
              return ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.showCheckbox)
                      Checkbox(
                        value: selectedMembers.contains(user),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              selectedMembers.add(user);
                            } else {
                              selectedMembers.remove(user);
                            }
                            ref
                                .watch(selectedMembersProvider.notifier)
                                .update((selectedMembers) => selectedMembers);
                          });

                          if (widget.onSelected != null) {
                            widget.onSelected!.call();
                          }
                        },
                      ),
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        user.photoUrl == null || user.photoUrl!.isEmpty
                            ? 'https://api.dicebear.com/9.x/thumbs/png?seed=${user.id ?? ''}'
                            : user.photoUrl!,
                      ),
                    ),
                  ],
                ),
                title: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: ThemeUtils.getTextColorForBackground(
                      widget.backgroundColor,
                    ),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
                trailing: PopupMenuButton<String>(
                  tooltip: 'More options',
                  onSelected: (String value) {
                    if (value == 'remove') {
                      Utils.displayDialog(
                        context: context,
                        title: 'Remove from org',
                        content:
                            'Are you sure you want to remove ${user.displayName ?? '${user.firstName} ${user.lastName}'} from the organization?',
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await ref
                                  .watch(invitationServiceProvider.notifier)
                                  .leaveOrganization(user.id!);

                              await Utils.sendEmail(
                                user,
                                Message(
                                  subject: 'Organization Removal',
                                  text:
                                      'You have been removed from the organization. If you believe this is a mistake, please contact the organization administrator.',
                                ),
                              );

                              if (!context.mounted) return;

                              Navigator.of(context).pop();

                              Utils.displayDialog(
                                context: context,
                                lottieAsset: 'assets/anim/congrats.json',
                                title: 'Removed from org successfully',
                                content:
                                    'You have successfully removed ${user.displayName ?? '${user.firstName} ${user.lastName}'} from the organization.',
                              );
                              setState(() {
                                widget.members.remove(user);
                              });
                            },
                            child: Text('Remove'),
                          ),
                        ],
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Text('Remove from org'),
                      ),
                    ];
                  },
                  icon: Icon(Icons.more_vert,
                      color: ThemeUtils.getTextColorForBackground(
                          widget.backgroundColor)),
                ),
              );
            },
          ),
        ),
        if (widget.members.length > widget.itemsPerPage)
          _buildPaginationControls(),
      ],
    );
  }

  int _getRemainingItems() {
    return widget.members.length -
        (ref.watch(currentPageProvider) * widget.itemsPerPage);
  }

  List<AppUser> _getPaginatedMembers() {
    final startIndex = ref.watch(currentPageProvider) * widget.itemsPerPage;
    final endIndex = (ref.watch(currentPageProvider) + 1) * widget.itemsPerPage;
    return widget.members.sublist(
      startIndex,
      endIndex > widget.members.length ? widget.members.length : endIndex,
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (widget.members.length / widget.itemsPerPage).ceil();
    final currentPage = ref.watch(currentPageProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: currentPage > 0
              ? () {
                  ref.watch(currentPageProvider.notifier).update(
                      (currentPage) => currentPage > 0 ? currentPage - 1 : 0);
                  _updateVisibleMembers();
                }
              : null,
          icon: Icon(
            Icons.arrow_back,
            color: currentPage > 0
                ? ThemeUtils.getTextColorForBackground(widget.backgroundColor)
                : widget.backgroundColor.computeLuminance() > 0.5
                    ? Colors.grey[400]
                    : Colors.grey[800],
          ),
        ),
        Text(
          'Page ${currentPage + 1} of $totalPages',
          style: TextStyle(
              color:
                  ThemeUtils.getTextColorForBackground(widget.backgroundColor)),
        ),
        IconButton(
          onPressed: currentPage < totalPages - 1
              ? () {
                  ref.watch(currentPageProvider.notifier).update(
                      (currentPage) => currentPage < totalPages - 1
                          ? currentPage + 1
                          : totalPages - 1);
                  _updateVisibleMembers();
                }
              : null,
          icon: Icon(
            Icons.arrow_forward,
            color: currentPage < totalPages - 1
                ? ThemeUtils.getTextColorForBackground(widget.backgroundColor)
                : widget.backgroundColor.computeLuminance() > 0.5
                    ? Colors.grey[400]
                    : Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
