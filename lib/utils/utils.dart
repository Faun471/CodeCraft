import 'dart:typed_data';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:url_launcher/url_launcher.dart';

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
      dialogWidth: 0.45,
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
                    iconColor: ThemeUtils.getTextColorForBackground(
                      Theme.of(context).primaryColor,
                    ),
                    text: buttonText,
                    iconData: Icons.close,
                    color: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                        color: ThemeUtils.getTextColorForBackground(
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

  static Future<Uint8List?> pickImage(BuildContext context,
      {ImageSource imageSource = ImageSource.gallery}) async {
    final pickedImage = await ImagePicker().pickImage(source: imageSource);

    if (pickedImage == null || pickedImage.path.isEmpty || !context.mounted) {
      return null;
    }

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Theme.of(context).primaryColor,
          toolbarWidgetColor: ThemeUtils.getTextColorForBackground(
            Theme.of(context).primaryColor,
          ),
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
          ],
        ),
        WebUiSettings(
            context: context,
            themeData: WebThemeData(
              rotateIconColor: AdaptiveTheme.of(context).mode.isDark
                  ? Colors.white
                  : Colors.black,
            )),
      ],
    );

    return croppedFile?.readAsBytes();
  }

  static Future<void> sendEmail(AppUser member, Message message) async {
    await DatabaseHelper().firestore.collection('mail').add(
      {
        'to': member.email,
        'message': message.toMap(),
      },
    );
  }
}

class Mail {
  String to;
  Message message;

  Mail({required this.to, required this.message});

  Map<String, dynamic> toMap() {
    return {
      'to': to,
      'message': message.toMap(),
    };
  }

  factory Mail.fromMap(Map<String, dynamic> map) {
    return Mail(
      to: map['to'],
      message: Message.fromMap(map['message']),
    );
  }
}

class Message {
  String subject;
  String text;

  Message({required this.subject, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'subject': subject,
      'text': text,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      subject: map['subject'],
      text: map['text'],
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
