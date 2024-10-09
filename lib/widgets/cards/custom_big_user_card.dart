import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class UserCard extends StatelessWidget {
  final Color? backgroundColor;
  final double? cardRadius;
  final Color? backgroundMotifColor;
  final Widget? cardActionWidget;
  final String userName;
  final String userLevel;
  final String userEmail;
  final String userProfilePicUrl;
  final double? height;

  const UserCard({
    super.key,
    this.backgroundColor,
    this.cardRadius = 30,
    required this.userName,
    required this.userLevel,
    required this.userEmail,
    this.backgroundMotifColor,
    this.cardActionWidget,
    this.height,
    required this.userProfilePicUrl,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final cardColor = backgroundColor ?? Theme.of(context).cardColor;
    final motifColor = backgroundMotifColor ?? Colors.white.withOpacity(0.1);

    return Container(
      height: height ?? (isSmallScreen ? 200 : 250),
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(cardRadius!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardRadius!),
        child: Stack(
          children: [
            // Background motifs
            Positioned(
              right: -50,
              top: -50,
              child: CircleAvatar(
                radius: 100,
                backgroundColor: motifColor,
              ),
            ),
            Positioned(
              left: -50,
              bottom: -50,
              child: CircleAvatar(
                radius: 120,
                backgroundColor: motifColor,
              ),
            ),
            // Main content
            Row(
              children: [
                // User profile image
                if (!isSmallScreen)
                  Expanded(
                    flex: 2,
                    child: CachedNetworkImage(
                      imageUrl: userProfilePicUrl,
                      fit: BoxFit.cover,
                      height: double.infinity,
                      placeholder: (context, url) =>
                          const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                    ),
                  ),
                // User info
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSmallScreen)
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                CachedNetworkImageProvider(userProfilePicUrl),
                          ),
                        const SizedBox(height: 8),
                        AutoSizeText(
                          userName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ThemeUtils.getTextColorForBackground(
                                        cardColor)
                                    .withOpacity(0.9),
                              ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 8),
                        AutoSizeText(
                          "Level: $userLevel",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: ThemeUtils.getTextColorForBackground(
                                            cardColor)
                                        .withOpacity(0.7),
                                  ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 4),
                        AutoSizeText(
                          userEmail,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: ThemeUtils.getTextColorForBackground(
                                            cardColor)
                                        .withOpacity(0.7),
                                  ),
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Edit profile button
            if (cardActionWidget != null)
              Positioned(
                right: 16,
                top: 16,
                child: cardActionWidget!,
              ),
          ],
        ),
      ),
    );
  }
}
