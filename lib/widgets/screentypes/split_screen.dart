import 'package:flutter/material.dart';

class DraggableSplitScreen extends StatefulWidget {
  final Widget leftWidget;
  final Widget rightWidget;
  final bool isVertical;

  const DraggableSplitScreen({
    super.key,
    required this.leftWidget,
    required this.rightWidget,
    this.isVertical = false,
  });

  @override
  DraggableSplitScreenState createState() => DraggableSplitScreenState();
}

class DraggableSplitScreenState extends State<DraggableSplitScreen> {
  double leftWidthFraction = 0.5;
  late bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return widget.isVertical
            ? Column(children: buildChildren(constraints))
            : Row(children: buildChildren(constraints));
      },
    );
  }

  List<Widget> buildChildren(BoxConstraints constraints) {
    return [
      Expanded(
        flex: (leftWidthFraction * 100).toInt(),
        child: widget.leftWidget,
      ),
      Expanded(
        child: Opacity(
          opacity: isHovering ? 0.7 : 0.1,
          child: Container(
            color: Colors.grey,
            child: MouseRegion(
              hitTestBehavior: HitTestBehavior.translucent,
              onHover: (event) => setState(() => isHovering = true),
              onExit: (event) => setState(() => isHovering = false),
              cursor: widget.isVertical
                  ? SystemMouseCursors.resizeRow
                  : SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onHorizontalDragUpdate: widget.isVertical
                    ? null
                    : (DragUpdateDetails details) {
                        setState(() {
                          leftWidthFraction +=
                              details.delta.dx / constraints.maxWidth;
                          leftWidthFraction = leftWidthFraction.clamp(0.2, 0.8);
                        });
                      },
                onVerticalDragUpdate: widget.isVertical
                    ? (DragUpdateDetails details) {
                        setState(() {
                          leftWidthFraction +=
                              details.delta.dy / constraints.maxHeight;
                          leftWidthFraction = leftWidthFraction.clamp(0.2, 0.8);
                        });
                      }
                    : null,
              ),
            ),
          ),
        ),
      ),
      Expanded(
        flex: ((1 - leftWidthFraction) * 100).toInt(),
        child: widget.rightWidget,
      ),
    ];
  }
}
