import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PrimaryButton extends StatelessWidget {
  final String buttonText;
  const PrimaryButton({super.key, required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height * 0.08,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Provider.of<ThemeProvider>(context).preferredColor,
      ),
      child: AutoSizeText(
        buttonText,
      ),
    );
  }
}
