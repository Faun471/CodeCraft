import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:markdown/markdown.dart' as md;

final draculaTheme = <String, TextStyle>{
  'root': GoogleFonts.robotoMono(
      backgroundColor: Colors.black,
      color: Colors.white,
      decorationStyle: TextDecorationStyle.solid,
      decorationColor: Colors.white,
      decorationThickness: 1.0,
      decoration: TextDecoration.none,
      fontSize: 16.0,
      height: 1.5,
      letterSpacing: 0.5,
      wordSpacing: 1.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      fontFeatures: null,
      textBaseline: TextBaseline.alphabetic),
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

class CodeElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  CodeElementBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';
    if (element.attributes['class'] != null) {
      String lg = element.attributes['class'] as String;
      language = lg.substring(9);
    }

    if (element.textContent.contains('\n')) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Container(
          color: Colors.black,
          child: HighlightView(
            element.textContent,
            language: language,
            theme: draculaTheme,
            padding: const EdgeInsets.all(8),
            textStyle: GoogleFonts.robotoMono(),
          ),
        ),
      );
    } else {
      return RichText(
        text: TextSpan(
          text: element.textContent,
          style: TextStyle(
            fontFamily: GoogleFonts.robotoMono().fontFamily,
            fontSize: 14,
            color: Colors.black,
            backgroundColor: Colors.grey[200],
          ),
        ),
      );
    }
  }
}
