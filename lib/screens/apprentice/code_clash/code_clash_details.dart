import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/screens/apprentice/code_clash/code_clash_lobby_screen.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/services/code_clash_service.dart';

class CodeClashDetailScreen extends ConsumerWidget {
  final CodeClash codeClash;

  const CodeClashDetailScreen({super.key, required this.codeClash});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          codeClash.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeUtils.getTextColorForBackground(
                Theme.of(context).primaryColor),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context, codeClash),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => _joinCodeClash(context, ref),
                child: Text(
                  'Join Code Clash',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color:
                        ThemeUtils.getTextColorForBackground(
                        Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, CodeClash codeClash) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              codeClash.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              codeClash.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
                context, 'Time Limit', '${codeClash.timeLimit} minutes'),
            _buildInfoRow(context, 'Status', codeClash.status),
            const SizedBox(height: 16),
            Text(
              'Instructions:',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(codeClash.instructions),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _joinCodeClash(BuildContext context, WidgetRef ref) async {
    final appUser = ref.read(appUserNotifierProvider).value;
    if (appUser == null) return;

    try {
      await CodeClashService().joinCodeClash(
          codeClash.id,
          CodeClashParticipant(
            id: FirebaseAuth.instance.currentUser!.uid,
            displayName: appUser.displayName ?? 'User',
            score: 0,
            photoUrl: appUser.photoUrl,
          ));
      if (!context.mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CodeClashLobbyScreen(codeClash: codeClash),
        ),
      );
    } catch (e) {
      Utils.displayDialog(
        context: context,
        title: 'Failed to join Code Clash',
        content: e.toString(),
      );
    }
  }
}
