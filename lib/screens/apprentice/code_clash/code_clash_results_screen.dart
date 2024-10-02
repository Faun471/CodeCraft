import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/models/submission.dart';
import 'package:codecraft/services/code_clash_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LeaderboardScreen extends ConsumerWidget {
  final String codeClashId;
  final String organizationId;

  const LeaderboardScreen({
    super.key,
    required this.codeClashId,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeClashFuture = ref.watch(codeClashFutureProvider(CodeClashParams(
      organizationId: organizationId,
      codeClashId: codeClashId,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard',
            style: TextStyle(
                color: ThemeUtils.getTextColor(
              Theme.of(context).primaryColor,
            ))),
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.75),
      body: codeClashFuture.when(
        data: (codeClash) => _buildLeaderboard(context, codeClash),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, CodeClash codeClash) {
    final submissionsStream = CodeClashService().getSubmissionsStream(
      organizationId,
      codeClash.id,
    );

    return StreamBuilder<List<Submission>>(
      stream: submissionsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final submissions = snapshot.data!;
          final participantsScores = <String, int>{};

          for (var submission in submissions) {
            final userId = submission.userId;
            final score = submission.score;

            if (participantsScores.containsKey(userId)) {
              participantsScores[userId] = participantsScores[userId]! + score;
            } else {
              participantsScores[userId] = score;
            }
          }

          final sortedParticipants = participantsScores.entries.map((entry) {
            return CodeClashParticipant(
              id: entry.key,
              displayName: submissions
                  .firstWhere((s) => s.userId == entry.key)
                  .displayName,
              score: entry.value,
              photoURL:
                  submissions.firstWhere((s) => s.userId == entry.key).photoURL,
            );
          }).toList();

          sortedParticipants.sort((a, b) => b.score.compareTo(a.score));

          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 640,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Logo
                          Image.asset(
                            'assets/images/logo.png',
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                          // Title
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              AutoSizeText(
                                'FINAL LEADERBOARD',
                                maxFontSize: 24,
                                style: TextStyle(
                                  color: ThemeUtils.getTextColor(
                                    Theme.of(context).primaryColor,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                codeClash.title,
                                style: TextStyle(
                                  color: ThemeUtils.getTextColor(
                                    Theme.of(context).primaryColor,
                                  ).withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Leaderboard List
                    Expanded(
                      child: ListView.builder(
                        itemCount: sortedParticipants.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var participant = sortedParticipants[index];
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, left: 16.0),
                            child: LeaderboardRow(
                              rank: index + 1,
                              name: participant.displayName,
                              score: participant.score,
                              isTop: index < 3,
                              photoURL: participant.photoURL,
                            ),
                          );
                        },
                      ),
                    ),

                    // Footer
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CodeCraft',
                            style: TextStyle(
                              color: ThemeUtils.getTextColor(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          Text(
                            'Date: ${getDate(codeClash.startTime!.toDate())}',
                            style: TextStyle(
                              color: ThemeUtils.getTextColor(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  String getDate(DateTime? date) {
    return date?.toLocal().toString().split(' ')[0] ?? 'N/A';
  }
}

class LeaderboardRow extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final bool isTop;
  final String? photoURL;

  const LeaderboardRow({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.isTop,
    this.photoURL,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Row(
          children: [
            ClipOval(
              child: Container(
                color: isTop
                    ? Colors.amber
                    : Theme.of(context).colorScheme.onPrimary,
                width: 50,
                height: 50,
                child: Center(
                  child: Text(
                    '$rank',
                    style: TextStyle(
                      color: ThemeUtils.getTextColor(
                        isTop
                            ? Colors.amber
                            : Theme.of(context).colorScheme.onPrimary,
                      ),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Badge(
              backgroundColor: Colors.transparent,
              isLabelVisible: isTop,
              alignment: Alignment.topCenter,
              offset: const Offset(-11, -25),
              label: Image.asset(
                'assets/images/crown.png',
                width: 30,
                height: 30,
                alignment: Alignment.center,
                fit: BoxFit.contain,
              ),
              child: CircleAvatar(
                backgroundColor: Colors.teal,
                radius: 25,
                backgroundImage:
                    photoURL != null ? NetworkImage(photoURL!) : null,
                child: photoURL == null
                    ? const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: ThemeUtils.getTextColor(
                    Theme.of(context).primaryColor,
                  ),
                  fontSize: 18,
                ),
              ),
            ),
            Text(
              '$score pts',
              style: TextStyle(
                color: ThemeUtils.getTextColor(
                  Theme.of(context).primaryColor,
                ),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

final codeClashFutureProvider =
    FutureProvider.family<CodeClash, CodeClashParams>((ref, params) async {
  final codeClashService = CodeClashService();
  return await codeClashService.getCodeClash(
      params.organizationId, params.codeClashId);
});

class CodeClashParams {
  final String organizationId;
  final String codeClashId;

  CodeClashParams({
    required this.organizationId,
    required this.codeClashId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CodeClashParams &&
        other.organizationId == organizationId &&
        other.codeClashId == codeClashId;
  }

  @override
  int get hashCode => organizationId.hashCode ^ codeClashId.hashCode;
}
