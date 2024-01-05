import 'package:codecraft/parsers/code_element_builder.dart';
import 'package:codecraft/parsers/image_element_builder.dart';
import 'package:codecraft/parsers/link_element_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
        codeblockPadding: const EdgeInsets.all(16.0),
      ),
      builders: {
        'code': CodeElementBuilder(context),
        'img': ImageElementBuilder(context),
        'a': LinkElementBuilder(context),
      },
      softLineBreak: true,
    );
  }
}
