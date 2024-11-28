import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';

class OnboardingCard extends StatelessWidget {
  final String image, title, description, buttonText;
  final Function onPressed;

  const OnboardingCard({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.80,
      width: 600,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Image.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                verticalDirection: VerticalDirection.up,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 8),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: AdaptiveTheme.of(context)
                          .theme
                          .textTheme
                          .displaySmall!
                          .copyWith(
                            color: AdaptiveTheme.of(context).theme.brightness ==
                                    Brightness.light
                                ? Colors.black
                                : Colors.white,
                          ),
                    ),
                  ),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AdaptiveTheme.of(context)
                        .theme
                        .textTheme
                        .displayLarge!
                        .copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  )
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => onPressed(),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(60),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
