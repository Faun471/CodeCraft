import 'package:codecraft/widgets/markdown_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Module extends StatelessWidget {
  final String markdown;
  final String quizName;

  const Module({Key? key, required this.markdown, required this.quizName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder(
        future: loadMarkdown(),
        builder: (context, snapshot) {
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
            return MarkdownViewer(
                markdownData: Future.value(snapshot.data as String),
                quizName: quizName);
          }
        },
      ),
    );
  }

  Future<String> loadMarkdown() async {
    return await rootBundle.loadString(markdown);
  }
}
