import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  LinkElementBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return RichText(
      text: TextSpan(
        text: element.textContent,
        style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
            fontSize: 18,
            fontFamily: GoogleFonts.poppins().fontFamily),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
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
                        launchUrl(Uri.parse(element.attributes['href']!));
                      },
                      text: 'Yes',
                      iconData: Icons.check_circle,
                      color: Colors.green,
                      textStyle: const TextStyle(color: Colors.white),
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
                      textStyle: const TextStyle(color: Colors.white),
                      iconColor: Colors.white,
                    );
                  },
                )
              ],
              title: 'Are you sure?',
              msg: 'You are about to open an external link and leave the app.',
            );
          },
      ),
    );
  }
}
