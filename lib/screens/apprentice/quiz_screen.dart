import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/services/quiz_service.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/viewers/quiz_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class QuizScreen extends ConsumerWidget {
  final String quizId;

  const QuizScreen({super.key, required this.quizId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appUser = ref.watch(appUserNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _onWillPop(context),
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _onWillPop(context);
        },
        child: FutureBuilder(
          future: QuizService().getQuizFromId(quizId, appUser.value!.orgId!),
          builder: (context2, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: Colors.white,
                  size: 200,
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return QuizViewer(
                quiz: snapshot.data!,
                onQuizFinished: (passed, quiz) {
                  Navigator.pop(context, {'passed': passed, 'quiz': quiz});
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _onWillPop(BuildContext context) async {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        Utils.displayDialog(
          context: context,
          title: 'Exit',
          content: 'Are you sure you want to exit? Your progress will be lost.',
          buttonText: 'Back to quiz.',
          onPressed: () => Navigator.pop(context),
          lottieAsset: 'assets/anim/question.json',
          actions: [
            Builder(
                builder: (dialogContext) => IconsButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      text: 'Back to quiz.',
                      color: const Color.fromARGB(255, 17, 172, 77),
                      iconData: Icons.cancel_outlined,
                      textStyle:
                          const TextStyle(color: Colors.white, fontSize: 16),
                      iconColor: Colors.white,
                    )),
            Builder(
              builder: (dialogContext) => IconsButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                },
                text: 'Quit.',
                iconData: Icons.check_circle,
                iconColor: Colors.white,
                color: Colors.red,
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
