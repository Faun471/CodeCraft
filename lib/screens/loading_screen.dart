import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:logging/logging.dart';

class LoadingScreen extends StatefulWidget {
  final List<Future> futures;
  final Function(BuildContext, AsyncSnapshot)? onDone;

  const LoadingScreen({
    super.key,
    required this.futures,
    this.onDone,
  });

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: Future.wait(widget.futures),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            Logger('Loading Screen')
                .info('LoadingScreen: All futures completed');

            Future.delayed(
              20.milliseconds,
              () {
                if (widget.onDone != null && context.mounted) {
                  widget.onDone!(context, snapshot);
                }
              },
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildLogo(context),
                _buildLoadingAnimation(context),
                const SizedBox(height: 20),
                _buildLoadingText(context),
              ]
                  .animate(delay: const Duration(seconds: 1))
                  .scaleXY(
                      curve: Curves.easeInOutCubicEmphasized,
                      duration: const Duration(seconds: 1))
                  .fade(
                      curve: Curves.easeOutBack,
                      duration: const Duration(seconds: 1)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Image.asset(
      'assets/images/ccOrangeLogo.png',
      width: MediaQuery.of(context).size.width * 0.5,
      height: MediaQuery.of(context).size.height * 0.5,
    );
  }

  Widget _buildLoadingAnimation(BuildContext context) {
    return LoadingAnimationWidget.flickr(
      leftDotColor: Theme.of(context).primaryColor,
      rightDotColor: Theme.of(context).colorScheme.secondary,
      size: MediaQuery.of(context).size.width * 0.1,
    );
  }

  Widget _buildLoadingText(BuildContext context) {
    return Text(
      'Loading...',
      style: Theme.of(context).textTheme.displayMedium,
    );
  }
}
