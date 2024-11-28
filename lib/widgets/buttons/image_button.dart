import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageRadioButton extends StatelessWidget {
  final String image;
  final String value;
  final String text;
  final String description;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const ImageRadioButton({
    required this.image,
    required this.text,
    required this.value,
    required this.description,
    this.isSelected = false,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(true),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[200]!,
            width: 2,
          ),
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.grey[200],
        ),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.black,
                        ),
                  ),
                ],
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
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  const ImageRadioButtonGroup({
    required this.buttons,
    this.padding = 10,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
    super.key,
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
    widget.controller?.selectedValue = _selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: widget.mainAxisAlignment,
      crossAxisAlignment: widget.crossAxisAlignment,
      children: _buildButtons(),
    );
  }

  List<Widget> _buildButtons() {
    return widget.buttons.map((button) {
      return Padding(
        padding: EdgeInsets.all(widget.padding),
        child: ImageRadioButton(
          image: button.image,
          text: button.text,
          value: button.value,
          description: button.description,
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
      );
    }).toList();
  }
}

class ImageRadioButtonController extends ChangeNotifier {
  String? _selectedValue;

  String? get selectedValue => _selectedValue;

  set selectedValue(String? value) {
    if (_selectedValue != value) {
      _selectedValue = value;
      notifyListeners();
    }
  }
}
