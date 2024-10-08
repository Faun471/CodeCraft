import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/widgets/screentypes/logo_with_background.dart';
import 'package:flutter/material.dart';

class AccountSetup extends StatefulWidget {
  final Widget child;

  const AccountSetup(this.child, {super.key});

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
        automaticallyImplyLeading: false,
        title: Text(
          'Account Setup',
          style: TextStyle(
            color: ThemeUtils.getTextColorForBackground(
                Theme.of(context).primaryColor),
          ),
        ),
      ),
      body: Row(
        children: [
          if (!isVertical) LogoWithBackground(isVertical: isVertical),
          Expanded(
            child: ListView(
              shrinkWrap: false,
              children: [
                if (isVertical) LogoWithBackground(isVertical: isVertical),
                widget.child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
