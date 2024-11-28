import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/screens/mentor/challenges/create_challenge_screen.dart';
import 'package:codecraft/screens/mentor/challenges/manage_challenges_screen.dart';
import 'package:codecraft/screens/mentor/code_clash/create_code_clash.dart';
import 'package:codecraft/screens/mentor/code_clash/manage_code_clashes_screen.dart';
import 'package:codecraft/screens/mentor/debugging_challenge/create_debugging_challenge.dart';
import 'package:codecraft/screens/mentor/debugging_challenge/manage_debugging_challenge.dart';
import 'package:codecraft/screens/mentor/paginated_leaderboard.dart';
import 'package:codecraft/screens/mentor/paginated_members.dart';
import 'package:codecraft/screens/mentor/quizzes/create_quiz_screen.dart';
import 'package:codecraft/screens/mentor/quizzes/manage_quizzes_screen.dart';
import 'package:codecraft/services/challenge_service.dart';
import 'package:codecraft/services/code_clash_service.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/services/debugging_challenge_service.dart';
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
      child: MediaQuery.of(context).size.width > 768
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
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color:
                            ThemeUtils.adjustColorBrightness(Colors.blue[50]!)
                                .withOpacity(0.5),
                        blurRadius: 7,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _buildCategorySection(
                    'Top Apprentices',
                    Colors.blue[50]!,
                    _buildLeaderboardList(ref, itemsPerPage: 8),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeUtils.adjustColorBrightness(Colors.red[50]!)
                            .withOpacity(0.5),
                        blurRadius: 7,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: _buildCategorySection(
                    'Organization Members',
                    Colors.red[50]!,
                    _buildMembersList(ref, itemsPerPage: 8),
                  ),
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
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          padding: EdgeInsets.all(16),
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
        Container(
          height: MediaQuery.of(context).size.height * 0.3,
          padding: EdgeInsets.all(16),
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
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: ThemeUtils.adjustColorBrightness(Colors.blue[50]!)
                      .withOpacity(0.5),
                  blurRadius: 7,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _buildCategorySection(
              'Top Apprentices',
              Colors.blue[50]!,
              _buildLeaderboardList(ref),
              scrollable: false,
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: ThemeUtils.adjustColorBrightness(Colors.red[50]!)
                      .withOpacity(0.5),
                  blurRadius: 7,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _buildCategorySection(
              'Organization Members',
              Colors.red[50]!,
              _buildMembersList(ref),
              scrollable: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
      String title, Stream<int> countStream, Color color) {
    Widget manageScreen = Container();
    Widget createScreen = Container();

    switch (title) {
      case 'Coding Challenges':
        manageScreen = ManageChallengesScreen();
        createScreen = CreateChallengeScreen();
        break;
      case 'Debugging Challenges':
        manageScreen = ManageDebuggingChallengesScreen();
        createScreen = CreateDebuggingChallengeScreen();
        break;
      case 'Coding Quizzes':
        manageScreen = ManageQuizzesScreen();
        createScreen = CreateQuizScreen();
        break;
      case 'Code Clash':
        manageScreen = ManageCodeClashesScreen();
        createScreen = CreateCodeClashScreen();
        break;
    }

    return StreamBuilder<int>(
      stream: countStream,
      builder: (context, snapshot) {
        final count = snapshot.data?.toString() ?? '0';
        return InkWell(
          onTap: () =>
              ref.watch(screenProvider.notifier).pushScreen(manageScreen),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color:
                      ThemeUtils.adjustColorBrightness(color).withOpacity(0.5),
                  blurRadius: 7,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: AutoSizeText(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ThemeUtils.getTextColorForBackground(color),
                    ),
                    presetFontSizes: [20, 16],
                    maxLines: 2,
                    overflow: TextOverflow.fade,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    count,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ThemeUtils.getTextColorForBackground(color),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ThemeUtils.adjustColorBrightness(color),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 7,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        ref
                            .watch(screenProvider.notifier)
                            .pushScreen(createScreen);
                      },
                      icon: Icon(
                        Icons.add,
                        size: 16,
                        color: ThemeUtils.getTextColorForBackground(color),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMembersList(WidgetRef ref, {int itemsPerPage = 9}) {
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

        if (members.isEmpty) {
          return Center(
            child: Text(
              'No members available.',
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return PaginatedMembersList(
          members: members,
          backgroundColor: Colors.red[50]!,
          itemsPerPage: itemsPerPage,
          showCheckbox: false,
        );
      },
    );
  }

  Widget _buildLeaderboardList(WidgetRef ref, {int itemsPerPage = 8}) {
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

        if (leaderboardData.isEmpty) {
          return Center(
            child: Text(
              'No leaderboard data available.',
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        return PaginatedLeaderboard(
          leaderboardData: leaderboardData,
          sortBy: _sortBy,
          itemsPerPage: itemsPerPage,
        );
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
                tooltip: 'Sort by',
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

    return scrollable ? SingleChildScrollView(child: content) : content;
  }
}
