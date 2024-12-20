import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CopiableText extends StatefulWidget {
  final String text;

  const CopiableText({super.key, required this.text});

  @override
  _CopiableTextState createState() => _CopiableTextState();
}

class _CopiableTextState extends State<CopiableText> {
  bool _isCopied = false;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.text,
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: Icon(
              _isCopied ? Icons.check : Icons.copy,
              size: 18,
              color: AdaptiveTheme.of(context).brightness == Brightness.light
                  ? Colors.grey[700]
                  : Colors.grey[300],
            ),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: widget.text));
              setState(() => _isCopied = true);
              await Future.delayed(const Duration(seconds: 2));
              setState(() => _isCopied = false);
            },
          ),
        ],
      ),
    );
  }
}
