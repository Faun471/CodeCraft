import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingScreen extends StatefulWidget {
  final List<Future> futures;
  final Function(BuildContext, AsyncSnapshot)? onDone;

  const LoadingScreen({
    Key? key,
    required this.futures,
    this.onDone,
  }) : super(key: key);

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
            Future.delayed(
              1.5.seconds,
              () {
                widget.onDone?.call(context, snapshot);
              },
            );
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Image.asset(
                  'assets/images/ccOrangeLogo.png',
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.height * 0.5,
                ),
              ),
              LoadingAnimationWidget.flickr(
                leftDotColor: Theme.of(context).primaryColor,
                rightDotColor: Theme.of(context).colorScheme.secondary,
                size: MediaQuery.of(context).size.width * 0.1,
              ),
              const SizedBox(height: 20),
              Text(
                'Loading...',
                style: Theme.of(context).textTheme.displayMedium,
              )
            ]
                .animate(delay: 1.seconds)
                .scaleXY(
                    curve: Curves.easeInOutCubicEmphasized,
                    duration: 1.5.seconds)
                .fade(curve: Curves.easeOutBack, duration: 1.seconds),
          );
        },
      ),
    );
  }
}
