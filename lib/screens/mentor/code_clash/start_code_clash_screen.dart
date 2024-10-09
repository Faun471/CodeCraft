import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:codecraft/models/code_clash.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/services/code_clash_service.dart';
import 'package:codecraft/providers/screen_provider.dart';
import 'package:codecraft/utils/theme_utils.dart';

class StartCodeClashScreen extends ConsumerStatefulWidget {
  final CodeClash codeClash;

  const StartCodeClashScreen({super.key, required this.codeClash});

  @override
  _StartCodeClashScreenState createState() => _StartCodeClashScreenState();
}

class _StartCodeClashScreenState extends ConsumerState<StartCodeClashScreen> {
  late Stream<CodeClash> _codeClashStream;

  @override
  void initState() {
    super.initState();
    final user = ref.read(appUserNotifierProvider).value;
    if (user != null) {
      _codeClashStream = CodeClashService().getCodeClashStream(
        user.orgId!,
        widget.codeClash.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CodeClash>(
      stream: _codeClashStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final codeClash = snapshot.data ?? widget.codeClash;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(context, codeClash),
                const SizedBox(height: 24),
                _buildParticipantsList(codeClash),
                const SizedBox(height: 24),
                _buildStartButton(context, codeClash),
              ],
            ),
          ),
        );
      },
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

  Widget _buildParticipantsList(CodeClash codeClash) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Participants',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                AnimatedCount(
                  count: codeClash.participants.length,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (codeClash.participants.isEmpty)
              const Center(
                child: Text('No participants yet'),
              ),
            if (codeClash.participants.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: codeClash.participants.length,
                itemBuilder: (context, index) {
                  final participant = codeClash.participants[index];
                  return ListTile(
                    title: Text(participant.displayName),
                    leading: CircleAvatar(
                      child: CachedNetworkImage(
                        imageUrl: participant.photoUrl ?? '',
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, CodeClash codeClash) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: codeClash.status == 'pending'
            ? () => _startCodeClash(
                  context,
                  ref,
                  codeClash.id,
                  codeClash,
                )
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        icon: const Icon(Icons.play_arrow),
        label: Text(
          'Start Code Clash',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ThemeUtils.getTextColorForBackground(
                Theme.of(context).primaryColor),
          ),
        ),
      ),
    );
  }

  void _startCodeClash(
    BuildContext context,
    WidgetRef ref,
    String codeClashId,
    CodeClash codeClash,
  ) async {
    final user = ref.read(appUserNotifierProvider).value;
    if (user == null) return;

    if (codeClash.participants.length < 2) {
      Utils.displayDialog(
        context: context,
        title: 'Whoops!',
        content: 'Need at least 2 participants to start Code Clash',
        lottieAsset: 'assets/anim/error.json',
      );

      return;
    }

    try {
      await CodeClashService().startCodeClash(user.orgId!, codeClashId);

      if (!context.mounted) return;

      Utils.displayDialog(
        context: context,
        title: 'Code Clash Started!',
        content: 'Code Clash has been started successfully',
        lottieAsset: 'assets/anim/success.json',
      );

      ref.read(screenProvider.notifier).popScreen();
    } catch (e) {
      Utils.displayDialog(
        context: context,
        title: 'Error!',
        content: 'Failed to start Code Clash: $e',
        lottieAsset: 'assets/anim/error.json',
      );
    }
  }
}

class AnimatedCount extends StatefulWidget {
  final int count;
  final Duration duration;
  final TextStyle? style;

  const AnimatedCount({
    super.key,
    required this.count,
    this.duration = const Duration(milliseconds: 500),
    this.style,
  });

  @override
  _AnimatedCountState createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late int _oldCount;

  @override
  void initState() {
    super.initState();
    _oldCount = widget.count;
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation =
        Tween<double>(begin: _oldCount.toDouble(), end: widget.count.toDouble())
            .animate(_controller)
          ..addListener(() {
            setState(() {});
          });
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count != widget.count) {
      _oldCount = oldWidget.count;
      _animation = Tween<double>(
              begin: _oldCount.toDouble(), end: widget.count.toDouble())
          .animate(_controller);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_animation.value.toInt()}',
      style: widget.style,
    );
  }
}
