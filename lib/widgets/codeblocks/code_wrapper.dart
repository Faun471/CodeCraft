import 'package:codecraft/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeWrapperWidget extends StatefulWidget {
  final Widget child;
  final String text;
  final String language;
  final SyntaxTheme theme;

  const CodeWrapperWidget(this.child, this.text, this.language,
      {super.key, required this.theme});

  @override
  State<CodeWrapperWidget> createState() => _PreWrapperState();
}

class _PreWrapperState extends State<CodeWrapperWidget> {
  late Widget _switchWidget;
  bool hasCopied = false;

  @override
  void initState() {
    super.initState();
    _switchWidget = Icon(
      Icons.copy_rounded,
      key: UniqueKey(),
      color: widget.theme.isLight ? Colors.black : Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.theme.root.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          width: double.infinity,
          child: widget.child,
        ),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.language.isNotEmpty)
                  SelectionContainer.disabled(
                    child: Container(
                      margin: const EdgeInsets.only(right: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: widget.theme.root.backgroundColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          width: 0.5,
                          color: widget.theme.isLight
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                      child: Text(
                        widget.language,
                        style: TextStyle(
                          color: widget.theme.isLight
                              ? Colors.black
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                InkWell(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _switchWidget,
                  ),
                  onTap: () async {
                    if (hasCopied) return;
                    await Clipboard.setData(ClipboardData(text: widget.text));
                    _switchWidget = Icon(
                      Icons.check,
                      key: UniqueKey(),
                      color: widget.theme.isLight ? Colors.black : Colors.white,
                    );
                    refresh();
                    Future.delayed(const Duration(seconds: 2), () {
                      hasCopied = false;
                      _switchWidget = Icon(Icons.copy_rounded,
                          key: UniqueKey(),
                          color: widget.theme.isLight
                              ? Colors.black
                              : Colors.white);
                      refresh();
                    });
                  },
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
