import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/mentor/challenges/manage_challenges_screen.dart';
import 'package:codecraft/screens/mentor/code_clash/manage_code_clashes_screen.dart';
import 'package:codecraft/screens/mentor/debugging_challenge/manage_debugging_challenge.dart';
import 'package:codecraft/screens/mentor/quizzes/manage_quizzes_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/code_clash_service.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/services/debugging_challenge_service.dart';
import 'package:codecraft/services/invitation_service.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MentorDashboard extends ConsumerStatefulWidget {
  const MentorDashboard({super.key});

  @override
  _MentorDashboardState createState() => _MentorDashboardState();
}

class _MentorDashboardState extends ConsumerState<MentorDashboard> {
  String _sortBy = 'quizzes';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: MediaQuery.of(context).size.width > 600
          ? _buildDesktopLayout()
          : SingleChildScrollView(child: _buildMobileLayout()),
    );
  }

  Widget _buildDesktopLayout() {
    final appUser = ref.read(appUserNotifierProvider).value!;
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: _buildDashboardCard(
                  'Coding Challenges',
                  ChallengeService().streamChallengesCount(appUser.orgId!),
                  Colors.purple[50]!,
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                fit: FlexFit.loose,
                child: _buildDashboardCard(
                  'Debugging Challenges',
                  DebuggingChallengeService()
                      .streamDebuggingChallengeCount(appUser.orgId!),
                  Colors.green[50]!,
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                fit: FlexFit.loose,
                child: _buildDashboardCard(
                  'Coding Quizzes',
                  QuizService().streamQuizzesCount(appUser.orgId!),
                  Colors.orange[50]!,
                ),
              ),
              SizedBox(width: 16),
              Flexible(
                fit: FlexFit.loose,
                child: _buildDashboardCard(
                  'Code Clash',
                  CodeClashService()
                      .streamActiveCodeClashesCount(appUser.orgId!),
                  Colors.pink[50]!,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Expanded(
                child: _buildCategorySection(
                  'Top Apprentices',
                  Colors.blue[50]!,
                  _buildLeaderboardList(ref),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildCategorySection(
                  'Organization Members',
                  Colors.red[50]!,
                  _buildMembersList(ref),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  'Coding Challenges',
                  ChallengeService().streamChallengesCount(
                    ref.read(appUserNotifierProvider).value!.orgId!,
                  ),
                  Colors.purple[50]!,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDashboardCard(
                  'Debugging Challenges',
                  DebuggingChallengeService().streamDebuggingChallengeCount(
                    ref.read(appUserNotifierProvider).value!.orgId!,
                  ),
                  Colors.green[50]!,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  'Coding Quizzes',
                  QuizService().streamQuizzesCount(
                    ref.read(appUserNotifierProvider).value!.orgId!,
                  ),
                  Colors.orange[50]!,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildDashboardCard(
                  'Code Clash',
                  CodeClashService().streamActiveCodeClashesCount(
                    ref.read(appUserNotifierProvider).value!.orgId!,
                  ),
                  Colors.pink[50]!,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          color: Colors.blue[50],
          child: _buildCategorySection(
            'Top Apprentices',
            Colors.blue[50]!,
            _buildLeaderboardList(ref),
            scrollable: false,
          ),
        ),
        SizedBox(height: 16),
        Container(
          height: MediaQuery.of(context).size.height * 0.7,
          color: Colors.red[50],
          child: _buildCategorySection(
            'Organization Members',
            Colors.red[50]!,
            _buildMembersList(ref),
            scrollable: false,
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
      String title, Stream<int> countStream, Color color) {
    Widget screenToPush = Container();

    switch (title) {
      case 'Coding Challenges':
        screenToPush = ManageChallengesScreen();
        break;
      case 'Debugging Challenges':
        screenToPush = ManageDebuggingChallengesScreen();
        break;
      case 'Coding Quizzes':
        screenToPush = ManageQuizzesScreen();
        break;
      case 'Code Clash':
        screenToPush = ManageCodeClashesScreen();
        break;
    }

    return StreamBuilder<int>(
      stream: countStream,
      builder: (context, snapshot) {
        final count = snapshot.data?.toString() ?? '0';
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: ThemeUtils.getTextColorForBackground(color),
                ),
                maxLines: 2,
                maxFontSize: 24,
                minFontSize: 14,
              ),
              Spacer(),
              Text(
                count,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ThemeUtils.getTextColorForBackground(color)),
              ),
              Row(
                children: [
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      ref
                          .watch(screenProvider.notifier)
                          .pushScreen(screenToPush);
                    },
                    icon: Icon(
                      Icons.fullscreen,
                      size: 16,
                      color: ThemeUtils.getTextColorForBackground(color),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersList(WidgetRef ref) {
    final appUser = ref.read(appUserNotifierProvider).value!;

    return FutureBuilder<List<AppUser>>(
      future: DatabaseHelper().getOrganizationMembers(appUser.orgId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final members = snapshot.data ?? [];
        members.removeWhere((user) => user.accountType == 'mentor');

        return PaginatedMembersList(members: members);
      },
    );
  }

  Widget _buildLeaderboardList(WidgetRef ref) {
    final appUser = ref.read(appUserNotifierProvider).value!;
    Stream<List<AppUser>> stream;

    if (_sortBy == 'quizzes') {
      stream = DatabaseHelper().getQuizLeaderboardStream(appUser.orgId!);
    } else if (_sortBy == 'challenges') {
      stream = DatabaseHelper().getChallengesLeaderboardStream(appUser.orgId!);
    } else {
      stream = DatabaseHelper().getLevelsLeaderboardStream(appUser.orgId!);
    }

    return StreamBuilder<List<AppUser>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final leaderboardData = snapshot.data ?? [];
        leaderboardData.removeWhere((user) => user.accountType == 'mentor');

        return PaginatedLeaderboard(
            leaderboardData: leaderboardData, sortBy: _sortBy);
      },
    );
  }

  Widget _buildCategorySection(String title, Color color, Widget child,
      {scrollable = false}) {
    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            AutoSizeText(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: ThemeUtils.getTextColorForBackground(color),
              ),
            ),
            Spacer(),
            if (title == 'Top Apprentices')
              PopupMenuButton<String>(
                onSelected: (String newValue) {
                  setState(() {
                    _sortBy = newValue;
                  });
                },
                itemBuilder: (BuildContext context) {
                  return <String>['quizzes', 'challenges', 'levels']
                      .map<PopupMenuItem<String>>((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(
                        value.capitalize(),
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList();
                },
                child: Row(
                  children: [
                    Text(
                      _sortBy.capitalize(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ThemeUtils.getTextColorForBackground(
                          Colors.blue[50]!,
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.black54),
                  ],
                ),
              ),
          ],
        ),
        Expanded(child: child),
      ],
    );

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: scrollable ? SingleChildScrollView(child: content) : content,
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
  final int _itemsPerPage = 6;

  @override
  Widget build(BuildContext context) {
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
                  style: TextStyle(
                    color:
                        ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
                  ),
                ),
                subtitle: Text(
                  'Level ${user.level ?? 0}',
                  style: TextStyle(
                    color: ThemeUtils.getTextColorForBackground(
                      Colors.blue[50]!,
                    ),
                  ),
                ),
                trailing: PopupMenuButton<String>(
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
                            onPressed: () {
                              ref
                                  .watch(invitationServiceProvider.notifier)
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
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Text('Remove from org'),
                      ),
                    ];
                  },
                  icon: Icon(Icons.more_vert, color: Colors.black54),
                ),
              );
            },
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  int _getRemainingItems() {
    return widget.members.length - (_currentPage * _itemsPerPage);
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
          icon: Icon(
            Icons.arrow_back,
            color: ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
          ),
        ),
        Text(
          'Page ${_currentPage + 1} of $totalPages',
          style: TextStyle(
            color: ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
          ),
        ),
        IconButton(
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
          icon: Icon(
            Icons.arrow_forward,
            color: ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
          ),
        ),
      ],
    );
  }
}

class PaginatedLeaderboard extends StatefulWidget {
  final List<AppUser> leaderboardData;
  final String sortBy;

  const PaginatedLeaderboard(
      {super.key, required this.leaderboardData, required this.sortBy});

  @override
  _PaginatedLeaderboardState createState() => _PaginatedLeaderboardState();
}

class _PaginatedLeaderboardState extends State<PaginatedLeaderboard> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final paginatedLeaderboard = _getPaginatedLeaderboard();

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: paginatedLeaderboard.length,
            itemBuilder: (context, index) {
              final user = paginatedLeaderboard[index];
              return _buildLeaderboardItem(
                  user, _currentPage * _itemsPerPage + index + 1);
            },
          ),
        ),
        _buildPaginationControls(),
      ],
    );
  }

  List<AppUser> _getPaginatedLeaderboard() {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = (_currentPage + 1) * _itemsPerPage;
    return widget.leaderboardData.sublist(
      startIndex,
      endIndex > widget.leaderboardData.length
          ? widget.leaderboardData.length
          : endIndex,
    );
  }

  Widget _buildPaginationControls() {
    final totalPages = (widget.leaderboardData.length / _itemsPerPage).ceil();

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
          icon: Icon(
            Icons.arrow_back,
            color: ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
          ),
        ),
        Text('Page ${_currentPage + 1} of $totalPages',
            style: TextStyle(
              color: ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
            )),
        IconButton(
          onPressed: _currentPage < totalPages - 1
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
          icon: Icon(
            Icons.arrow_forward,
            color: ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(AppUser user, int rank) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$rank.',
            style: TextStyle(
              color: ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(
              user.photoUrl == null || user.photoUrl!.isEmpty
                  ? 'https://api.dicebear.com/9.x/thumbs/png?seed=${user.id ?? ''}'
                  : user.photoUrl!,
            ),
            radius: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              user.displayName ?? '${user.firstName} ${user.lastName}',
              style: TextStyle(
                color: ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _getScoreText(
              user,
            ),
            style: TextStyle(
              color: ThemeUtils.getTextColorForBackground(Colors.blue[50]!),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _getScoreText(AppUser user) {
    if (widget.sortBy == 'quizzes') {
      return '${user.quizResults.length} quizzes';
    } else if (widget.sortBy == 'challenges') {
      return '${(user.completedChallenges ?? []).length} challenges';
    } else {
      return 'Level ${user.level}';
    }
  }
}
