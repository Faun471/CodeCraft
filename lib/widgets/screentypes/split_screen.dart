import 'package:flutter/material.dart';

class DraggableSplitScreen extends StatefulWidget {
  final Widget leftWidget;
  final Widget rightWidget;
  const DraggableSplitScreen({
    super.key,
    required this.leftWidget,
    required this.rightWidget,
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
        return Row(
          children: [
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
                    cursor: SystemMouseCursors.resizeColumn,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (DragUpdateDetails details) {
                        setState(() {
                          leftWidthFraction +=
                              details.delta.dx / constraints.maxWidth;
                          leftWidthFraction = leftWidthFraction.clamp(0.1, 0.9);
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: ((1 - leftWidthFraction) * 100).toInt(),
              child: widget.rightWidget,
            ),
          ],
        );
      },
    );
  }
}
