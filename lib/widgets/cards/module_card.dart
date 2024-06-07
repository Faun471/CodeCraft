import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ModuleCard extends ConsumerStatefulWidget {
  final String title;
  final String description;
  final String? imageUrl;
  final IconData iconData;
  final VoidCallback onTap;
  final double imageWidthPercentage;
  final int unlockLevel;
  final Color backgroundColor;
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final Color iconColor;

  const ModuleCard({
    super.key,
    required this.title,
    required this.onTap,
    required this.unlockLevel,
    this.description = '',
    this.imageUrl,
    this.iconData = Icons.remove_circle,
    this.imageWidthPercentage = 20.0,
    this.backgroundColor = Colors.white,
    this.titleStyle = const TextStyle(fontSize: 24),
    this.descriptionStyle = const TextStyle(fontSize: 18),
    this.iconColor = Colors.red,
  });

  @override
  ModuleCardState createState() => ModuleCardState();
}

class ModuleCardState extends ConsumerState<ModuleCard> {
  @override
  Widget build(BuildContext context) {
    final appUser = ref.read(appUserNotifierProvider).value!;

    int currentLevel = appUser.data['level'] ?? 0;
    double screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = screenWidth * (widget.imageWidthPercentage / 100);
    bool isLocked = currentLevel < widget.unlockLevel;
    Color iconColor = !isLocked ? Colors.green : widget.iconColor;
    IconData iconData = !isLocked ? Icons.check : widget.iconData;

    return GestureDetector(
      onTap: isLocked
          ? () {
              Utils.displayDialog(
                context: context,
                title: 'Module Locked',
                content: 'You have not unlocked this module yet!',
                buttonText: 'Okay!',
                lottieAsset: 'assets/anim/locked.json',
                onPressed: () {
                  Navigator.pop(context);
                },
              );
            }
          : widget.onTap,
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
      ),
    );
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
