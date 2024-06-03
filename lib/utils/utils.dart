import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class Utils {
  static void displayDialog({
    required BuildContext context,
    required String title,
    required String content,
    String? buttonText,
    Function? onPressed,
    Function? onDismiss,
    bool isDismissible = true,
    String? lottieAsset,
    List<Widget>? actions,
  }) {
    Dialogs.materialDialog(
      context: context,
      msg: content,
      titleStyle: Theme.of(context).textTheme.displayLarge!.copyWith(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white),
      title: title,
      msgStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.light
              ? Colors.black
              : Colors.white),
      lottieBuilder: lottieAsset != null
          ? Lottie.asset(
              lottieAsset,
              fit: BoxFit.contain,
              alignment: Alignment.center,
              repeat: false,
            )
          : null,
      dialogWidth: 0.25,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color.fromARGB(255, 21, 21, 21),
      actions: actions ??
          [
            buttonText != null && buttonText.isNotEmpty && isDismissible
                ? IconsButton(
                    onPressed: () {
                      if (onPressed != null) {
                        onPressed();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    text: buttonText,
                    iconData: Icons.close,
                    color: Theme.of(context).primaryColorDark,
                    textStyle: const TextStyle(
                      color: Colors.white,
                    ),
                  )
                : Container()
          ],
    );
  }

  static String toSnakeCase(String text) {
    return text.replaceAllMapped(
        RegExp(r'[A-Z]'),
        (Match match) =>
            (match.start > 0 ? '_' : '') + match.group(0)!.toLowerCase());
  }
}
