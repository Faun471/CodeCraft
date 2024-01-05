import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/providers/level_provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CustomListItem extends StatefulWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final IconData iconData;
  final VoidCallback onTap;
  final Color backgroundColor;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final Color iconColor;
  final double imageWidthPercentage;
  final int unlockLevel;

  const CustomListItem({
    Key? key,
    required this.title,
    this.description = '',
    this.imageUrl,
    this.iconData = Icons.remove_circle,
    required this.onTap,
    this.backgroundColor = Colors.white,
    this.titleStyle = const TextStyle(fontWeight: FontWeight.bold),
    this.descriptionStyle = const TextStyle(color: Colors.grey),
    this.iconColor = Colors.red,
    this.imageWidthPercentage = 20.0, // Default to 20%
    required this.unlockLevel, // Default unlock level
  }) : super(key: key);

  @override
  CustomListItemState createState() => CustomListItemState();
}

class CustomListItemState extends State<CustomListItem> {
  late bool isLocked;

  @override
  void initState() {
    super.initState();
    updateLockState();
  }

  void updateLockState() {
    int currentLevel =
        Provider.of<LevelProvider>(context, listen: false).currentLevel;
    setState(() {
      isLocked = currentLevel < widget.unlockLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = screenWidth * (widget.imageWidthPercentage / 100);

    return Consumer<LevelProvider>(builder: (context, levelProvider, child) {
      bool isLocked = levelProvider.currentLevel < widget.unlockLevel;

      Color iconColor = levelProvider.currentLevel >= widget.unlockLevel
          ? Colors.green
          : widget.iconColor;
      IconData iconData = levelProvider.currentLevel >= widget.unlockLevel
          ? Icons.check_circle
          : widget.iconData;

      return GestureDetector(
          onTap: isLocked
              ? () {
                  Dialogs.materialDialog(
                      color: Colors.white,
                      msg: 'You have not unlocked this module yet!',
                      title: 'Module Locked',
                      lottieBuilder: Lottie.asset(
                        'assets/anim/locked.json',
                        fit: BoxFit.contain,
                      ),
                      context: context,
                      actions: [
                        Builder(
                          builder: (dialogContext) => IconsButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            text: 'Okay!',
                            iconData: Icons.done,
                            color: Colors.blue,
                            textStyle: const TextStyle(color: Colors.white),
                            iconColor: Colors.white,
                          ),
                        ),
                      ]);
                }
              : () {
                  widget.onTap();
                  // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
                  levelProvider.notifyListeners();
                },
          child: Stack(
            children: [
              Container(
                color: widget.backgroundColor,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildImage(imageWidth),
                    Expanded(
                      flex: 8,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              widget.title,
                              style: widget.titleStyle,
                              presetFontSizes: const [28, 24, 12],
                              maxLines: 1,
                            ),
                            if (widget.description.isNotEmpty)
                              AutoSizeText(
                                widget.description,
                                style: widget.descriptionStyle,
                                presetFontSizes: const [18, 14, 10],
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          return Icon(
                            iconData,
                            color: iconColor,
                            size: constraints.biggest.width / 2.5,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              if (isLocked) Positioned.fill(child: _buildLockedOverlay()),
            ],
          ));
    });
  }

  Widget _buildImage(double width) {
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      if (widget.imageUrl!.startsWith('http')) {
        // Network image
        return ClipRect(
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl!,
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white, size: 50),
            errorWidget: (context, url, error) =>
                const Icon(Icons.error, color: Colors.red),
            width: width,
            height: width * 3 / 4,
            fit: BoxFit.contain,
          ),
        );
      } else {
        // Asset image
        return ClipRect(
          child: Image.asset(
            widget.imageUrl!,
            width: width,
            height: width * 3 / 4,
            fit: BoxFit.contain,
          ),
        );
      }
    } else {
      return SizedBox(
        width: width,
        height: width * 3 / 4,
      );
    }
  }

  Widget _buildLockedOverlay() {
    return Container(
      color: const Color.fromARGB(255, 96, 96, 96).withOpacity(0.9),
      child: const Center(
          child: Icon(
        Icons.lock,
        color: Colors.white,
        size: 40.0,
      )),
    );
  }
}
