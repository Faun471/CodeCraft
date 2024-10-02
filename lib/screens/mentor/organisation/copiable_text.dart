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
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(text: widget.text));
        setState(() => _isCopied = true);
        await Future.delayed(const Duration(seconds: 2));
        setState(() => _isCopied = false);
      },
      child: _isCopied
          ? const Row(children: [
              Icon(Icons.check),
              SizedBox(width: 4),
              Text('Copied!')
            ])
          : Text(widget.text, style: const TextStyle(fontSize: 16)),
    );
  }
}
