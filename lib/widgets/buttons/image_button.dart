import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageRadioButton extends StatelessWidget {
  final String image;
  final String value;
  final String text;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const ImageRadioButton({
    required this.image,
    required this.text,
    required this.value,
    this.isSelected = false,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

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
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRect(
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    isSelected ? Colors.transparent : Colors.black,
                    BlendMode.saturation,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(image),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: isSelected ? Colors.white : Colors.black,
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

  const ImageRadioButtonGroup({
    required this.buttons,
    this.padding = 10,
    this.isVertical = false,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
    Key? key,
  }) : super(key: key);

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
    return widget.buttons.map((button) {
      return Padding(
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
