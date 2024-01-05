import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:markdown/markdown.dart' as md;

class ImageElementBuilder extends MarkdownElementBuilder {
  final BuildContext context;

  ImageElementBuilder(this.context);

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var url = element.attributes['src'];
    if (url == null) return null;

    return CachedNetworkImage(
      imageUrl: url,
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.white, size: 50),
      errorWidget: (context, url, error) =>
          const Center(child: Icon(Icons.error, color: Colors.red)),
      fit: BoxFit.contain,
    );
  }
}
