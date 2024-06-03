import 'package:flutter/material.dart';

class LogoWithBackground extends StatelessWidget {
  final bool isVertical;

  const LogoWithBackground({super.key, required this.isVertical});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isVertical
          ? MediaQuery.sizeOf(context).height / 2.5
          : MediaQuery.sizeOf(context).height,
      width: isVertical
          ? MediaQuery.sizeOf(context).width
          : (MediaQuery.sizeOf(context).width / 1.75),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight:
              isVertical ? const Radius.circular(0) : const Radius.circular(20),
          bottomRight:
              isVertical ? const Radius.circular(0) : const Radius.circular(20),
          bottomLeft:
              isVertical ? const Radius.circular(0) : const Radius.circular(0),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/bg-psych.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 25,
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                isVertical
                    ? 'assets/images/logo-hor.png'
                    : 'assets/images/logo-ver.png',
                width: isVertical
                    ? MediaQuery.sizeOf(context).width - 50
                    : MediaQuery.sizeOf(context).width / 2.5,
                height: isVertical
                    ? MediaQuery.sizeOf(context).height
                    : MediaQuery.sizeOf(context).height / 2.5,
                scale: isVertical ? 0.9 : 1.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
