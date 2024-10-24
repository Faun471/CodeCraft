import 'package:codecraft/models/app_user_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class OrganizationMembersList extends ConsumerStatefulWidget {
  final String userId;

  const OrganizationMembersList({super.key, required this.userId});

  @override
  _OrganizationMembersListState createState() =>
      _OrganizationMembersListState();
}

class _OrganizationMembersListState
    extends ConsumerState<OrganizationMembersList> {
  List<AppUser> _members = [];
  List<AppUser> _filteredMembers = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() async {
    final appUser = ref.watch(appUserNotifierProvider).requireValue;
    if (appUser.orgId != null) {
      final members =
          await DatabaseHelper().getOrganizationMembers(appUser.orgId!);
      setState(() {
        _members = members;
        _filteredMembers = members;
      });
    }
  }

  void _filterMembers(String query) {
    setState(() {
      _filteredMembers = _members.where((member) {
        final name = '${member.firstName} ${member.lastName}'.toLowerCase();
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Organization Members',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search members',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          onChanged: _filterMembers,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: PaginatedMembersList(members: _filteredMembers),
        ),
      ],
    );
  }
}

class PaginatedMembersList extends ConsumerStatefulWidget {
  final List<AppUser> members;

  const PaginatedMembersList({super.key, required this.members});

  @override
  _PaginatedMembersListState createState() => _PaginatedMembersListState();
}

class _PaginatedMembersListState extends ConsumerState<PaginatedMembersList> {
  int _currentPage = 0;
  final int _itemsPerPage = 12;

  @override
  Widget build(BuildContext context) {
    final paginatedMembers = _getPaginatedMembers();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: paginatedMembers.length,
            itemBuilder: (context, index) {
              final user = paginatedMembers[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                    user.photoUrl == null || user.photoUrl!.isEmpty
                        ? 'https://api.dicebear.com/9.x/thumbs/png?seed=${user.id ?? ''}'
                        : user.photoUrl!,
                  ),
                ),
                title: Text(
                  user.displayName ?? '${user.firstName} ${user.lastName}',
                ),
                subtitle: Text('Level ${user.level ?? 0}'),
                trailing: user.accountType != 'mentor'
                    ? PopupMenuButton<String>(
                        onSelected: (String value) {
                          if (value == 'remove') {
                            Utils.displayDialog(
                              context: context,
                              title: 'Remove from org',
                              content:
                                  'Are you sure you want to remove ${user.displayName ?? '${user.firstName} ${user.lastName}'} from the organization?',
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(
                                            invitationServiceProvider.notifier)
                                        .leaveOrganization(user.id!);
                                    Navigator.of(context).pop();
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
                        itemBuilder: (BuildContext context) => [
                          PopupMenuItem<String>(
                            value: 'remove',
                            child: Text('Remove from org'),
                          ),
                        ],
                        icon: Icon(Icons.more_vert),
                      )
                    : null,
              );
            },
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  List<AppUser> _getPaginatedMembers() {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (_currentPage + 1) * _itemsPerPage;
    return widget.members.sublist(
      startIndex,
      endIndex > widget.members.length ? widget.members.length : endIndex,
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (widget.members.length / _itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 0
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
          icon: Icon(Icons.arrow_back),
        ),
        Text('Page ${_currentPage + 1} of $totalPages'),
        IconButton(
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
          icon: Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}
