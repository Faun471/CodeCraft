import 'package:codecraft/widgets/logo_with_background.dart';
import 'package:flutter/material.dart';

class AccountSetup extends StatefulWidget {
  final Widget widget;

  const AccountSetup(this.widget, {Key? key}) : super(key: key);

  @override
  _AccountSetupState createState() => _AccountSetupState();
}

class _AccountSetupState extends State<AccountSetup> {
  late bool isVertical;

  @override
  Widget build(BuildContext context) {
    isVertical = MediaQuery.sizeOf(context).aspectRatio < 1.0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Setup'),
      ),
      body: Row(
        children: [
          if (!isVertical) LogoWithBackground(isVertical: isVertical),
          Expanded(
            child: ListView(
              shrinkWrap: false,
              children: [
                if (isVertical) LogoWithBackground(isVertical: isVertical),
                widget.widget,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
