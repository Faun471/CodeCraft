import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final Color? backgroundColor;
  final Color? settingColor;
  final double? cardRadius;
  final Color? backgroundMotifColor;
  final Widget? cardActionWidget;
  final String? userName;
  final Widget? userMoreInfo;
  final CachedNetworkImage userProfilePic;
  final double? height;

  const UserCard({
    super.key,
    this.backgroundColor,
    this.settingColor,
    this.cardRadius = 30,
    required this.userName,
    this.backgroundMotifColor = Colors.white,
    this.cardActionWidget,
    this.userMoreInfo,
    this.height,
    required this.userProfilePic,
  });

  @override
  Widget build(BuildContext context) {
    bool isVertical = MediaQuery.of(context).size.aspectRatio < 1;
    return Container(
      height: height ??
          (isVertical
              ? MediaQuery.of(context).size.height / 3.5
              : MediaQuery.of(context).size.height / 2),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).cardColor,
        borderRadius:
            BorderRadius.circular(double.parse(cardRadius!.toString())),
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: backgroundMotifColor!.withOpacity(.1),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: CircleAvatar(
              radius: 400,
              backgroundColor: backgroundMotifColor!.withOpacity(.05),
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: (cardActionWidget != null)
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // User profile
                    ClipOval(
                        clipBehavior: Clip.antiAlias, child: userProfilePic),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(right: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              userName!,
                              presetFontSizes: const [24, 20, 16, 12, 8],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.end,
                            ),
                            if (userMoreInfo != null) ...[
                              userMoreInfo!,
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  child: cardActionWidget ?? Container(),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
