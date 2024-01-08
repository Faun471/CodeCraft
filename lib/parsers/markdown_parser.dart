import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:markdown/markdown.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_syntax_view/flutter_syntax_view.dart';

final draculaTheme = <String, TextStyle>{
  'comment': const TextStyle(color: Color(0xff6272a4)),
  'quote': const TextStyle(color: Color(0xff6272a4)),
  'variable': const TextStyle(color: Color(0xfff8f8f2)),
  'template-variable': const TextStyle(color: Color(0xfff8f8f2)),
  'tag': const TextStyle(color: Color(0xff8be9fd)),
  'name': const TextStyle(color: Color(0xff8be9fd)),
  'selector-id': const TextStyle(color: Color(0xff8be9fd)),
  'selector-class': const TextStyle(color: Color(0xff8be9fd)),
  'regexp': const TextStyle(color: Color(0xff50fa7b)),
  'meta': const TextStyle(color: Color(0xff50fa7b)),
  'number': const TextStyle(color: Color(0xffbd93f9)),
  'built_in': const TextStyle(color: Color(0xff50fa7b)),
  'builtin-name': const TextStyle(color: Color(0xff50fa7b)),
  'literal': const TextStyle(color: Color(0xff50fa7b)),
  'type': const TextStyle(color: Color(0xff50fa7b)),
  'params': const TextStyle(color: Color(0xfff8f8f2)),
  'string': const TextStyle(color: Color.fromARGB(255, 108, 255, 150)),
  'symbol': const TextStyle(color: Color(0xffff79c6)),
  'bullet': const TextStyle(color: Color(0xffff79c6)),
  'title': const TextStyle(color: Color(0xff8be9fd)),
  'section': const TextStyle(color: Color(0xff8be9fd)),
  'keyword': const TextStyle(color: Color(0xffc792ea)),
  'selector-tag': const TextStyle(color: Color(0xffc792ea)),
  'deletion': const TextStyle(color: Color(0xffff5555)),
  'addition': const TextStyle(color: Color(0xff50fa7b)),
  'attribute': const TextStyle(color: Color(0xff50fa7b)),
  'emphasis': const TextStyle(fontStyle: FontStyle.italic),
  'strong': const TextStyle(fontWeight: FontWeight.bold),
};

class MarkdownParser {
  static Widget parse({
    required BuildContext context,
    required String data,
  }) {
    return Markdown(
      data: data,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
        h1: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        h2: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        h3: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        p: const TextStyle(fontSize: 18),
        strong: const TextStyle(fontWeight: FontWeight.bold),
        em: const TextStyle(fontStyle: FontStyle.italic),
        blockSpacing: 8.0,
        listBullet: const TextStyle(fontSize: 16),
        listBulletPadding: const EdgeInsets.symmetric(horizontal: 8.0),
        listIndent: 24.0,
        blockquote: TextStyle(
            fontSize: 16, color: Colors.grey[800], fontStyle: FontStyle.italic),
        blockquotePadding: const EdgeInsets.all(16.0),
        blockquoteDecoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        img: const TextStyle(fontSize: 16),
        tableHead: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        tableBody: const TextStyle(fontSize: 16),
        tableBorder: TableBorder.all(color: Colors.grey),
        horizontalRuleDecoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey),
          ),
        ),
        h1Padding: const EdgeInsets.only(bottom: 16.0),
        h2Padding: const EdgeInsets.only(bottom: 8.0),
        h3Padding: const EdgeInsets.only(bottom: 4.0),
        h4Padding: const EdgeInsets.only(bottom: 4.0),
        h5Padding: const EdgeInsets.only(bottom: 4.0),
        h6Padding: const EdgeInsets.only(bottom: 4.0),
        pPadding: const EdgeInsets.only(bottom: 2.0),
        codeblockDecoration: BoxDecoration(
          color: const Color.fromARGB(255, 21, 21, 21),
          borderRadius: BorderRadius.circular(8.0),
        ),
        code: GoogleFonts.robotoMono(
          color: Colors.white,
          backgroundColor: const Color.fromARGB(255, 21, 21, 21),
          fontSize: 16.0,
          height: 1.5,
          letterSpacing: 0.5,
          wordSpacing: 1.0,
          fontWeight: FontWeight.normal,
          fontStyle: FontStyle.normal,
          fontFeatures: null,
          textBaseline: TextBaseline.alphabetic,
        ),
        codeblockAlign: WrapAlignment.start,
        codeblockPadding: const EdgeInsets.all(16.0),
      ),
      imageBuilder: (uri, title, alt) => CachedNetworkImage(
        imageUrl: uri.toString(),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white, size: 50),
        errorWidget: (context, url, error) =>
            const Center(child: Icon(Icons.error, color: Colors.red)),
        fit: BoxFit.contain,
      ),
      extensionSet: ExtensionSet.gitHubFlavored,
      onTapLink: (text, href, title) {
        Dialogs.bottomMaterialDialog(
          context: context,
          lottieBuilder: Lottie.asset(
            'assets/anim/question.json',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
          ),
          actions: [
            Builder(
              builder: (dialogContext) {
                return IconsButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    launchUrl(href! as Uri);
                  },
                  text: 'Yes',
                  iconData: Icons.check_circle,
                  color: Colors.green,
                  iconColor: Colors.white,
                );
              },
            ),
            Builder(
              builder: (dialogContext) {
                return IconsButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  text: 'No',
                  iconData: Icons.cancel_rounded,
                  color: Colors.red,
                  iconColor: Colors.white,
                );
              },
            )
          ],
          title: 'Are you sure?',
          msg: 'You are about to open an external link and leave the app.',
          titleStyle: AdaptiveTheme.of(context).mode.isLight
              ? const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 21, 21, 21),
                )
              : const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          msgStyle: AdaptiveTheme.of(context).mode.isLight
              ? const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 21, 21, 21),
                )
              : const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
          color: AdaptiveTheme.of(context).mode.isLight
              ? Colors.white
              : const Color.fromARGB(255, 21, 21, 21),
        );
      },
      syntaxHighlighter: _SyntaxHighlighter(),
    );
  }
}

class _SyntaxHighlighter extends SyntaxHighlighter {
  @override
  TextSpan format(String source) {
    return TextSpan(
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 16.0,
        height: 1.5,
        color: Colors.white,
        backgroundColor: Color.fromARGB(255, 21, 21, 21),
      ),
      children: <TextSpan>[
        JavaSyntaxHighlighter(SyntaxTheme.dracula()).format(source),
      ],
    );
  }
}
