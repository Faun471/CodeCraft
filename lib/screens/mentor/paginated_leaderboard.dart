import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class PaginatedLeaderboard extends StatefulWidget {
  final List<AppUser> leaderboardData;
  final String sortBy;
  final int itemsPerPage;

  const PaginatedLeaderboard({
    super.key,
    required this.leaderboardData,
    required this.sortBy,
    this.itemsPerPage = 10,
  });

  @override
  _PaginatedLeaderboardState createState() => _PaginatedLeaderboardState();
}

class _PaginatedLeaderboardState extends State<PaginatedLeaderboard> {
  int _currentPage = 0;
  @override
  Widget build(BuildContext context) {
    if (widget.leaderboardData.isEmpty) {
      return Center(
        child: Text(
          'No leaderboard data available.',
          style: TextStyle(
            color: Colors.black54,
          ),
        ),
      );
    }

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
                  user, _currentPage * widget.itemsPerPage + index + 1);
            },
          ),
        ),
        if (widget.leaderboardData.length > widget.itemsPerPage)
          _buildPaginationControls(),
      ],
    );
  }

  List<AppUser> _getPaginatedLeaderboard() {
    final startIndex = _currentPage * widget.itemsPerPage;
    final endIndex = (_currentPage + 1) * widget.itemsPerPage;
    return widget.leaderboardData.sublist(
      startIndex,
      endIndex > widget.leaderboardData.length
          ? widget.leaderboardData.length
          : endIndex,
    );
  }

  Widget _buildPaginationControls() {
    final totalPages =
        (widget.leaderboardData.length / widget.itemsPerPage).ceil();

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
            color: _currentPage > 0
                ? ThemeUtils.getTextColorForBackground(Colors.blue[50]!)
                : const Color.fromARGB(255, 200, 200, 200),
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
            color: _currentPage < totalPages - 1
                ? ThemeUtils.getTextColorForBackground(Colors.blue[50]!)
                : const Color.fromARGB(255, 200, 200, 200),
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
