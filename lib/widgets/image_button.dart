import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageRadioButton extends StatefulWidget {
  final String image;
  final String value;
  final String text;
  final bool isSelected;
  final Function(bool)? onChanged;

  ImageRadioButton({
    required this.image,
    required this.text,
    required this.value,
    this.isSelected = false,
    required this.onChanged,
  });

  @override
  _ImageRadioButtonState createState() => _ImageRadioButtonState();
}

class _ImageRadioButtonState extends State<ImageRadioButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onChanged!(true);
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey[200]!,
            width: 2,
          ),
          color: widget.isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[200],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRect(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    widget.isSelected ? Colors.transparent : Colors.black,
                    BlendMode.saturation,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(widget.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: widget.isSelected ? Colors.white : Colors.black,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageRadioButtonGroup extends StatefulWidget {
  final List<ImageRadioButton> buttons;
  final ImageRadioButtonController? controller;
  final double padding;
  final bool isVertical;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  ImageRadioButtonGroup({
    required this.buttons,
    this.padding = 10,
    this.isVertical = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
  });

  @override
  _ImageRadioButtonGroupState createState() => _ImageRadioButtonGroupState();
}

class _ImageRadioButtonGroupState extends State<ImageRadioButtonGroup> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.buttons.first.value;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.isVertical ? 1 : _buildButtons().length,
      ),
      itemCount: _buildButtons().length,
      itemBuilder: (BuildContext context, int index) {
        return _buildButtons()[index];
      },
    );
  }

  List<Widget> _buildButtons() {
    return widget.buttons
        .map((button) => Padding(
              padding: EdgeInsets.all(widget.padding),
              child: ImageRadioButton(
                image: button.image,
                text: button.text,
                value: button.value,
                isSelected: button.value == _selectedValue,
                onChanged: (isSelected) {
                  if (isSelected) {
                    setState(() {
                      _selectedValue = button.value;
                      widget.controller?.selectedValue = button.value;
                    });
                  }
                },
              ),
            ))
        .toList();
  }
}

class ImageRadioButtonController extends ChangeNotifier {
  String? _selectedValue;

  String? get selectedValue => _selectedValue;

  set selectedValue(String? value) {
    _selectedValue = value;
    notifyListeners();
  }
}
