import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class Utils {
  static Future<void> scrollableMaterialDialog({
    required BuildContext context,
    Function(dynamic value)? onClose,
    String? title,
    String? msg,
    List<Widget>? actions,
    Function(BuildContext context)? actionsBuilder,
    required Widget customView,
    CustomViewPosition customViewPosition = CustomViewPosition.BEFORE_TITLE,
    LottieBuilder? lottieBuilder,
    bool barrierDismissible = true,
    Color? barrierColor = Colors.black54,
    String? barrierLabel,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
    ShapeBorder dialogShape = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    TextStyle titleStyle =
        const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    TextStyle? msgStyle,
    TextAlign? titleAlign,
    TextAlign? msgAlign,
    Color? color,
    double? dialogWidth,
    double? maxHeight,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(16.0),
    ScrollPhysics? scrollPhysics,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AdaptiveTheme.of(context).mode.isDark
              ? color ?? const Color.fromARGB(255, 21, 21, 21)
              : color ?? Colors.white,
          shape: dialogShape,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8,
              maxWidth: dialogWidth ?? MediaQuery.of(context).size.width * 0.9,
            ),
            child: SingleChildScrollView(
              physics: scrollPhysics ?? const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: contentPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (customViewPosition == CustomViewPosition.BEFORE_TITLE)
                      customView,
                    if (lottieBuilder != null) lottieBuilder,
                    if (title != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          title,
                          style: titleStyle,
                          textAlign: titleAlign,
                        ),
                      ),
                    if (customViewPosition == CustomViewPosition.BEFORE_MESSAGE)
                      customView,
                    if (msg != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          msg,
                          style: msgStyle,
                          textAlign: msgAlign,
                        ),
                      ),
                    if (customViewPosition == CustomViewPosition.BEFORE_ACTION)
                      customView,
                    if (actions != null || actionsBuilder != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actionsBuilder != null
                              ? actionsBuilder(context)
                              : actions ?? [],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((value) => onClose?.call(value));
  }

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
      titleAlign: TextAlign.center,
      msgAlign: TextAlign.center,
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
      dialogWidth: 0.35,
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : const Color.fromARGB(255, 21, 21, 21),
      actionsBuilder: (context) =>
          actions ??
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
                    iconColor: ThemeUtils.getTextColor(
                      Theme.of(context).primaryColor,
                    ),
                    text: buttonText,
                    iconData: Icons.close,
                    color: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                        color: ThemeUtils.getTextColor(
                      Theme.of(context).primaryColor,
                    )),
                  )
                : Container()
          ],
      onClose: (_) {
        if (onDismiss != null) {
          onDismiss();
        }
      },
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  String toSnakeCase() {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (Match match) =>
          (match.start > 0 ? '_' : '') + match.group(0)!.toLowerCase(),
    );
  }
}
