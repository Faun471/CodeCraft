import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/screens/mentor/paginated_members.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/services/database_helper.dart';

class OrganizationMembersList extends ConsumerStatefulWidget {
  const OrganizationMembersList({super.key});

  @override
  _OrganizationMembersListState createState() =>
      _OrganizationMembersListState();
}

class _OrganizationMembersListState
    extends ConsumerState<OrganizationMembersList> {
  List<AppUser> _members = [];
  List<AppUser> _filteredMembers = [];
  String _filterBy = 'full name';
  String query = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadMembers();
    });
  }

  Future<void> _loadMembers() async {
    final appUser = ref.watch(appUserNotifierProvider).requireValue;
    if (appUser.orgId != null) {
      final members =
          (await DatabaseHelper().getOrganizationMembers(appUser.orgId!))
              .where((member) => member.accountType == 'apprentice')
              .toList();

      setState(() {
        _members = members;
        _filteredMembers = members;
      });
    }
  }

  void _filterMembers() {
    setState(() {
      _filteredMembers = _members.where((member) {
        final lowerCaseQuery = query.toLowerCase();
        switch (_filterBy) {
          case 'first name':
            final firstName = member.firstName?.toLowerCase() ?? '';
            return firstName.contains(lowerCaseQuery);
          case 'last name':
            final lastName = member.lastName?.toLowerCase() ?? '';
            return lastName.contains(lowerCaseQuery);
          case 'email':
            final email = member.email!.toLowerCase();
            return email.contains(lowerCaseQuery);
          case 'display name':
            final displayName = member.displayName?.toLowerCase() ?? '';
            return displayName.contains(lowerCaseQuery);
          case 'full name':
            final fullName =
                '${member.firstName} ${member.lastName}'.toLowerCase();
            return fullName.contains(lowerCaseQuery);
          default:
            return false;
        }
      }).toList();

      _filteredMembers.sort((a, b) {
        switch (_filterBy) {
          case 'first name':
            return a.firstName!
                .toLowerCase()
                .compareTo(b.firstName!.toLowerCase());
          case 'last name':
            return a.lastName!
                .toLowerCase()
                .compareTo(b.lastName!.toLowerCase());
          case 'email':
            return a.email!.toLowerCase().compareTo(b.email!.toLowerCase());
          case 'display name':
            return (a.displayName?.toLowerCase() ??
                    '${a.firstName} ${a.lastName}')
                .compareTo(b.displayName?.toLowerCase() ??
                    '${a.firstName} ${a.lastName}');
          case 'full name':
            final fullNameA = '${a.firstName} ${a.lastName}'.toLowerCase();
            final fullNameB = '${b.firstName} ${b.lastName}'.toLowerCase();
            return fullNameA.compareTo(fullNameB);
          default:
            return a.lastName!.compareTo(b.lastName!);
        }
      });
    });
  }

  void _selectAllMembers(bool selectAll) {
    final selectedMembers = ref.watch(selectedMembersProvider);
    final paginatedMembers = ref.watch(visibleMembersProvider);

    if (selectAll) {
      selectedMembers.addAll(
          paginatedMembers.where((user) => !selectedMembers.contains(user)));
    } else {
      selectedMembers.removeWhere((user) => paginatedMembers.contains(user));
    }

    ref.watch(selectedMembersProvider.notifier).update((members) {
      return selectedMembers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedMembers = ref.watch(selectedMembersProvider.notifier).state;
    final visibleMembers = ref.watch(visibleMembersProvider);

    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Organization Members',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: visibleMembers.isNotEmpty &&
                      visibleMembers
                          .every((member) => selectedMembers.contains(member)),
                  onChanged: (bool? value) {
                    setState(() {
                      _selectAllMembers(value!);
                    });
                  },
                ),
                Expanded(
                  child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search members',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        query = value;
                        _filterMembers();
                      }),
                ),
                PopupMenuButton<String>(
                  tooltip: 'Filter by',
                  icon: Icon(Icons.filter_list,
                      color: ThemeUtils.getTextColorForBackground(
                        Theme.of(context).scaffoldBackgroundColor,
                      )),
                  onSelected: (String newValue) {
                    setState(() {
                      _filterBy = newValue;

                      _filterMembers();
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return <String>[
                      'full name',
                      'first name',
                      'last name',
                      'email',
                      'display name',
                    ].map<PopupMenuItem<String>>((String value) {
                      return PopupMenuItem<String>(
                        value: value,
                        child: _filterBy == value
                            ? Row(
                                children: [
                                  Icon(
                                    Icons.check,
                                    color: AdaptiveTheme.of(context).mode.isDark
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(value.capitalize()),
                                ],
                              )
                            : Text(value.capitalize()),
                      );
                    }).toList();
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: selectedMembers.isEmpty
                        ? Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[700]
                            : Colors.grey[300]
                        : ThemeUtils.getTextColorForBackground(
                            Theme.of(context).scaffoldBackgroundColor),
                  ),
                  onPressed: selectedMembers.isNotEmpty
                      ? _deleteSelectedMembers
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 400,
              child: PaginatedMembersList(
                members: _filteredMembers,
                itemsPerPage: 7,
                title: _filterBy,
                backgroundColor: Theme.of(context).cardColor,
                showCheckbox: true,
                onSelected: () => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSelectedMembers() {
    final selectedMembers = ref.watch(selectedMembersProvider.notifier).state;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Members'),
          content: Text(
              'Are you sure you want to delete ${selectedMembers.length} members?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteMembers(selectedMembers);

                if (!context.mounted) return;

                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMembers(List<AppUser> members) async {
    for (final member in members) {
      await ref
          .watch(invitationServiceProvider.notifier)
          .leaveOrganization(member.id!);
    }

    if (!mounted) return;

    Utils.displayDialog(
      context: context,
      lottieAsset: 'assets/anim/congrats.json',
      title: 'Members Removed',
      content: 'The selected members have been removed from the organization.',
    );

    for (final member in members) {
      await Utils.sendEmail(
        member,
        Message(
          subject: 'Organization Removal',
          text:
              'You have been removed from the organization. If you believe this is a mistake, please contact the organization administrator.',
        ),
      );
    }

    await _loadMembers();
  }
}
