import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MentorDashboard extends ConsumerStatefulWidget {
  const MentorDashboard({super.key});

  @override
  _MentorDashboardState createState() => _MentorDashboardState();
}

class _MentorDashboardState extends ConsumerState<MentorDashboard> {
  String _sortBy = 'quizzes';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leaderboard',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.left,
          ),
          Divider(
            thickness: 2,
            color: Colors.black.withOpacity(0.1),
          ),
          const SizedBox(height: 10),
          _buildSearchAndSort(),
          const SizedBox(height: 10),
          Expanded(
            child: _buildLeaderboardList(),
          ),
        ],
      ),
    );
  }

  // Search and Sort UI
  Widget _buildSearchAndSort() {
    return Row(
      children: [
        // Search Bar
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),
        const SizedBox(width: 10),
        // Sort Dropdown
        DropdownButton<String>(
          value: _sortBy,
          onChanged: (value) {
            setState(() {
              _sortBy = value!;
            });
          },
          items: const [
            DropdownMenuItem(value: 'quizzes', child: Text('Quizzes')),
            DropdownMenuItem(value: 'challenges', child: Text('Challenges')),
            DropdownMenuItem(value: 'levels', child: Text('Levels')),
          ],
        ),
      ],
    );
  }

  // Leaderboard List with StreamBuilder
  Widget _buildLeaderboardList() {
    Stream<List<AppUser>> stream;

    final appUser = ref.read(appUserNotifierProvider).value!;

    // Select the correct stream based on sorting
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
          return const Center(child: CircularProgressIndicator());
        }

        final leaderboardData = snapshot.data ?? [];

        final filteredData = leaderboardData.where((user) {
          final displayName = user.displayName?.toLowerCase() ?? '';
          final email = user.email?.toLowerCase() ?? '';
          return displayName.contains(_searchQuery) ||
              email.contains(_searchQuery);
        }).toList();

        if (filteredData.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        // remove the mentor from the leaderboard
        filteredData.removeWhere((user) => user.accountType == 'mentor');

        return ListView.builder(
          itemCount: filteredData.length,
          itemBuilder: (context, index) {
            final user = filteredData[index];
            return _buildLeaderboardCard(user, index + 1);
          },
        );
      },
    );
  }

  // Leaderboard Card for each user
  Widget _buildLeaderboardCard(AppUser user, int rank) {
    Color cardColor;

    // Assign color based on rank
    switch (rank) {
      case 1:
        cardColor = Colors.amber.shade600; // Gold
        break;
      case 2:
        cardColor = Colors.grey.shade400; // Silver
        break;
      case 3:
        cardColor = Colors.brown.shade400; // Bronze
        break;
      default:
        cardColor = Theme.of(context).primaryColor; // Default theme color
    }

    return Card(
      color: cardColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Rank Container, spanning the full height of the card
            Container(
              width: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                color: Colors.black12,
              ),
              child: Text(
                '$rank',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Rest of the card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Profile Image
                    Column(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(user.photoURL ?? ''),
                          radius: 30,
                        ),
                        if (MediaQuery.of(context).size.width < 600)
                          Text(
                            user.displayName ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (MediaQuery.of(context).size.width > 600)
                            Text(
                              user.displayName ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (MediaQuery.of(context).size.width > 600)
                            Text(
                              user.email ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Quizzes and Challenges
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level: ${user.level ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Coding Challenges: ${user.completedChallenges?.length ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Debugging Challenges: ${user.completedDebuggingChallenges?.length ?? 0}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
