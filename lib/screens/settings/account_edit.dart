import 'dart:typed_data';

import 'package:codecraft/io/file_io.dart';
import 'package:codecraft/io/io.dart';
import 'package:codecraft/io/web_io.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/services/auth/auth_provider.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:logging/logging.dart';

class AccountEdit extends ConsumerStatefulWidget {
  const AccountEdit({super.key});

  @override
  AccountEditState createState() => AccountEditState();
}

class AccountEditState extends ConsumerState<AccountEdit> {
  late String imageUrl;
  late User? user;
  late TextEditingController displayNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController firstNameController;
  late TextEditingController miController;
  late TextEditingController lastNameController;
  late TextEditingController suffixController;
  late Uint8List imageFile = Uint8List(0);

  Io io = kIsWeb ? WebIo() : FileIo();
  bool imageChanged = false;

  @override
  void initState() {
    super.initState();
    displayNameController = TextEditingController();
    phoneNumberController = TextEditingController();
    firstNameController = TextEditingController();
    miController = TextEditingController();
    lastNameController = TextEditingController();
    suffixController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    user = FirebaseAuth.instance.currentUser;
    imageUrl = ref.read(authProvider).auth.currentUser!.photoURL ?? '';
    final userData = ref.watch(appUserNotifierProvider).value!.data;

    return Scaffold(
      body: Padding(
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
                      child: imageFile.isEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            )
                          : Image.memory(
                              Uint8List.fromList(imageFile),
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateColor.resolveWith(
                              (states) =>
                                  const Color.fromARGB(255, 212, 212, 212)
                                      .withOpacity(0.5))),
                      icon: const Icon(Icons.camera_alt),
                      onPressed: () async {
                        imageFile = await io.pickImage();

                        setState(() {
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
                  border: const OutlineInputBorder(),
                  labelText: 'Display Name',
                  prefixIcon: const Icon(Icons.person),
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
                color:
                    AdaptiveTheme.of(context).theme.textTheme.bodyMedium!.color,
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
              hintText: userData['phoneNumber'] ?? 'Enter your phone number',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: "First Name",
                        prefixIcon: const Icon(Icons.person),
                        hintText:
                            userData['firstName'] ?? 'Enter your first name',
                        helperText: 'Leave blank to keep the same first name'),
                    controller: firstNameController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: "MI",
                        hintText: userData['mi'] ?? 'Enter your middle initial',
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
                      border: const OutlineInputBorder(),
                      labelText: "Last Name",
                      prefixIcon: const Icon(Icons.person),
                      hintText: userData['lastName'] ?? 'Enter your last name',
                      helperText: 'Leave blank to keep the same last name',
                    ),
                    controller: lastNameController,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: TextField(
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: "Suffix",
                        hintText: userData['suffix'] ?? 'Enter your suffix',
                        helperText: 'Leave blank to keep the same suffix'),
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
                    minimumSize: WidgetStateProperty.resolveWith<Size?>(
                      (_) => const Size.fromHeight(60),
                    ),
                  ),
              onPressed: () async {
                if (imageChanged) {
                  await updateProfilePicture(user, imageFile);
                }

                await ref.read(authProvider).updateUser(
                      ref,
                      displayName: displayNameController.text,
                      phoneNumber: phoneNumberController.text,
                      firstName: firstNameController.text,
                      mi: miController.text,
                      lastName: lastNameController.text,
                      suffix: suffixController.text,
                    );

                clearControllers();
                imageChanged = false;

                if (!context.mounted) {
                  return;
                }

                Utils.displayDialog(
                  context: context,
                  lottieAsset: 'assets/anim/congrats.json',
                  title: 'Success',
                  content:
                      'Your account has been updated successfully. 🎉\nThe changes will be reflected shortly.',
                  onDismiss: (value) => setState(() {}),
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
      await io
          .uploadImageToStorage(imageFile)
          .then((value) async => await getDownloadLink(value));
    } catch (error) {
      Logger.root.severe('Error updating profile picture: $error');
    }
  }

  Future<String> getDownloadLink(String imageFile) async {
    String url = await io.getDownloadUrl(imageFile);
    await ref.watch(authProvider).auth.currentUser!.updatePhotoURL(url);
    ref.watch(appUserNotifierProvider.notifier).updateData({'photoURL': url});

    return url;
  }
}
