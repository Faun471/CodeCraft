import 'dart:typed_data';

import 'package:codecraft/io/file_io.dart';
import 'package:codecraft/io/io.dart';
import 'package:codecraft/io/web_io.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/services/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class AccountEdit extends StatefulWidget {
  const AccountEdit({super.key});

  @override
  AccountEditState createState() => AccountEditState();
}

class AccountEditState extends State<AccountEdit> {
  late String imageUrl;
  late User? user;
  late TextEditingController displayNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController firstNameController;
  late TextEditingController miController;
  late TextEditingController lastNameController;
  late TextEditingController suffixController;
  late Uint8List imageFile = Uint8List(0);

  late Map<String, dynamic> userData;

  Io io = kIsWeb ? WebIo() : FileIo();
  bool imageChanged = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    imageUrl = DatabaseHelper().auth.currentUser!.photoURL ?? '';
    user = DatabaseHelper().auth.currentUser;
    displayNameController = TextEditingController();
    phoneNumberController = TextEditingController();
    firstNameController = TextEditingController();
    miController = TextEditingController();
    lastNameController = TextEditingController();
    suffixController = TextEditingController();
    userData = {};

    if (userData.isNotEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUserData();
      print(userData);
    });
  }

  Future<void> getUserData() async {
    await DatabaseHelper().currentUser.get().then((value) {
      if (value.exists) {
        userData = value.data() as Map<String, dynamic>;
        userData['displayName'] = user!.displayName;
        print(user!.displayName);
      }

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: isLoading
          ? Center(
              child: LoadingAnimationWidget.bouncingBall(
                color: AdaptiveTheme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                size: 100,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromARGB(255, 28, 28, 28),
                              width: 1.0,
                            ),
                          ),
                          child: ClipOval(
                            child: imageUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    width: 150,
                                    height: 150,
                                  )
                                : Image.memory(Uint8List.fromList(imageFile),
                                    fit: BoxFit.cover, width: 150, height: 150),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: IconButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith(
                                    (states) =>
                                        const Color.fromARGB(255, 212, 212, 212)
                                            .withOpacity(0.5))),
                            icon: const Icon(Icons.camera_alt),
                            onPressed: () async {
                              imageFile = await io.pickImage();

                              setState(() {
                                imageUrl = '';
                                imageChanged = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Display Name',
                        prefixIcon: Icon(Icons.person),
                        hintText: userData['displayName'] ?? 'Enter your name',
                        helperText: 'Leave blank to keep the same name'),
                    controller: displayNameController,
                  ),
                  const SizedBox(height: 10),
                  InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {},
                    maxLength: 12,
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                      useBottomSheetSafeArea: true,
                      setSelectorButtonAsPrefixIcon: true,
                      leadingPadding: 20,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    selectorTextStyle: TextStyle(
                      color: AdaptiveTheme.of(context)
                          .theme
                          .textTheme
                          .bodyMedium!
                          .color,
                    ),
                    initialValue: PhoneNumber(
                      dialCode: "+63",
                      isoCode: "PH",
                    ),
                    textFieldController: phoneNumberController,
                    formatInput: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: true,
                      decimal: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '* This field is required';
                      }

                      if (value.length < 12) {
                        return 'Invalid phone number';
                      }

                      return null;
                    },
                    hintText:
                        userData['phoneNumber'] ?? 'Enter your phone number',
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "First Name",
                              prefixIcon: Icon(Icons.person),
                              hintText: userData['firstName'] ??
                                  'Enter your first name',
                              helperText:
                                  'Leave blank to keep the same first name'),
                          controller: firstNameController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "MI",
                              hintText:
                                  userData['mi'] ?? 'Enter your middle initial',
                              helperText: ''),
                          controller: miController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Last Name",
                            prefixIcon: Icon(Icons.person),
                            hintText:
                                userData['lastName'] ?? 'Enter your last name',
                            helperText:
                                'Leave blank to keep the same last name',
                          ),
                          controller: lastNameController,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Suffix",
                              hintText:
                                  userData['suffix'] ?? 'Enter your suffix',
                              helperText:
                                  'Leave blank to keep the same suffix'),
                          controller: suffixController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: AdaptiveTheme.of(context)
                        .theme
                        .elevatedButtonTheme
                        .style!
                        .copyWith(
                          minimumSize: MaterialStateProperty.resolveWith<Size?>(
                            (_) => const Size.fromHeight(60),
                          ),
                        ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });

                            await updateProfilePicture(user, imageFile);

                            await Auth(DatabaseHelper().auth).updateUser(
                              displayName: displayNameController.text,
                              photoUrl: imageChanged ? imageUrl : null,
                              firstName: firstNameController.text,
                              mi: miController.text,
                              lastName: lastNameController.text,
                              suffix: suffixController.text,
                              phoneNumber: phoneNumberController.text,
                            );

                            clearControllers();
                            imageChanged = false;

                            Dialogs.materialDialog(
                              context: context,
                              lottieBuilder: Lottie.asset(
                                'assets/anim/congrats.json',
                                repeat: false,
                                height: 100,
                                width: 100,
                                fit: BoxFit.contain,
                              ),
                              dialogWidth: 0.25,
                              title: 'Success',
                              titleStyle: TextStyle(
                                color: Color.fromARGB(255, 21, 21, 21),
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              msg:
                                  'Your account has been updated successfully. 🎉\nThe changes will be reflected shortly.',
                              msgStyle: TextStyle(
                                color: Color.fromARGB(255, 21, 21, 21),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              onClose: (value) => setState(() {
                                isLoading = false;
                              }),
                            );
                          },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }

  void clearControllers() {
    displayNameController.clear();
    phoneNumberController.clear();
    firstNameController.clear();
    miController.clear();
    lastNameController.clear();
    suffixController.clear();
  }

  Future<void> updateProfilePicture(
      User? currentUser, Uint8List imageFile) async {
    if (currentUser == null) {
      return;
    }

    try {
      io
          .uploadImageToStorage(imageFile)
          .then((value) async => getDownloadLink(value));
    } catch (error) {
      print("Error updating profile picture: $error");
    }
  }

  Future<String> getDownloadLink(String imageFile) async {
    String url = await io.getDownloadUrl(imageFile);
    await DatabaseHelper().auth.currentUser!.updatePhotoURL(url);

    return url;
  }
}
