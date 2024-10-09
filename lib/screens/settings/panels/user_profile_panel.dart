import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/io/file_io.dart';
import 'package:codecraft/io/io.dart';
import 'package:codecraft/io/web_io.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/services/auth/auth_helper.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/cards/custom_big_user_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:logging/logging.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';

class UserProfilePanel extends ConsumerStatefulWidget {
  const UserProfilePanel({super.key});

  @override
  _UserProfilePanelState createState() => _UserProfilePanelState();
}

class _UserProfilePanelState extends ConsumerState<UserProfilePanel> {
  late TextEditingController displayNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController firstNameController;
  late TextEditingController miController;
  late TextEditingController lastNameController;
  late TextEditingController suffixController;
  late Uint8List imageFile = Uint8List(0);

  Io io = kIsWeb ? WebIo() : FileIo();
  bool imageChanged = false;

  bool _isSaving = false;

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
    final appUserState = ref.watch(appUserNotifierProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            _buildUserCard(appUserState),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(AsyncValue<AppUser> appUserState) {
    return UserCard(
      userName: appUserState.value!.displayName ?? 'No Username',
      userEmail: appUserState.value!.email ?? 'No Email',
      userLevel: appUserState.value!.level.toString(),
      userProfilePicUrl: appUserState.value!.photoUrl == null ||
              appUserState.value!.photoUrl!.isEmpty
          ? FirebaseAuth.instance.currentUser!.photoURL ??
              'https://api.dicebear.com/9.x/thumbs/png?seed=${appUserState.value!.id!}'
          : appUserState.value!.photoUrl!,
      backgroundColor: Theme.of(context).primaryColor,
      cardActionWidget: IconsButton(
        iconData: Icons.edit,
        iconColor: ThemeUtils.getTextColorForBackground(
          Theme.of(context).primaryColor,
        ),
        onPressed: () {
          _showEditProfileDialog(context);
        },
        textStyle: TextStyle(
          color: ThemeUtils.getTextColorForBackground(
            Theme.of(context).primaryColor,
          ),
        ),
        text: 'Edit Profile',
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userData = ref.read(appUserNotifierProvider).value!;
    String imageUrl = user?.photoURL ?? '';

    Utils.scrollableMaterialDialog(
      context: context,
      title: 'Edit Profile',
      titleAlign: TextAlign.center,
      titleStyle: TextStyle(
        color: Theme.of(context).primaryColor,
        fontSize: 18.0,
      ),
      msg: 'Edit your profile here.',
      msgStyle: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium!.color,
        fontSize: 16.0,
      ),
      msgAlign: TextAlign.center,
      dialogWidth: MediaQuery.of(context).size.width * 0.8,
      maxHeight: MediaQuery.of(context).size.height * 0.8,
      customViewPosition: CustomViewPosition.BEFORE_ACTION,
      customView: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
                                        .withOpacity(0.5),
                              ),
                            ),
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
                      hintText: userData.displayName ?? 'Enter your name',
                      helperText: 'Leave blank to keep the same name',
                    ),
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
                    hintText: userData.phoneNumber ?? 'Enter your phone number',
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
                                userData.firstName ?? 'Enter your first name',
                            helperText:
                                'Leave blank to keep the same first name',
                          ),
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
                            hintText:
                                userData.mi ?? 'Enter your middle initial',
                            helperText: '',
                          ),
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
                            hintText:
                                userData.lastName ?? 'Enter your last name',
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
                            border: const OutlineInputBorder(),
                            labelText: "Suffix",
                            hintText: userData.suffix ?? 'Enter your suffix',
                            helperText: 'Leave blank to keep the same suffix',
                          ),
                          controller: suffixController,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actionsBuilder: (context) {
        return [
          StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return IconsButton(
                onPressed: () async {
                  if (_isSaving) return;

                  setDialogState(() => _isSaving = true);
                  try {
                    if (imageChanged) {
                      await updateProfilePicture(user, imageFile);
                    }

                    await ref.read(authProvider.notifier).updateUser(
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

                    if (!context.mounted) return;

                    Navigator.of(context).pop(); // Close the dialog

                    Utils.displayDialog(
                      context: context,
                      lottieAsset: 'assets/anim/congrats.json',
                      title: 'Success',
                      content:
                          'Your account has been updated successfully. 🎉\nThe changes will be reflected shortly.',
                      onDismiss: (value) => setState(() {}),
                    );
                  } finally {
                    if (mounted) {
                      setDialogState(() => _isSaving = false);
                    }
                  }
                },
                text: _isSaving ? 'Saving...' : 'Save',
                iconData: _isSaving ? Icons.hourglass_empty : Icons.save,
                color: _isSaving ? Colors.grey : Theme.of(context).primaryColor,
                textStyle: TextStyle(
                  color: _isSaving
                      ? Colors.grey[600]
                      : ThemeUtils.getTextColorForBackground(
                          Theme.of(context).primaryColor,
                        ),
                ),
                iconColor: _isSaving
                    ? Colors.grey[600]
                    : ThemeUtils.getTextColorForBackground(
                        Theme.of(context).primaryColor,
                      ),
              );
            },
          ),
          const SizedBox(width: 10),
          IconsButton(
            onPressed: () {
              if (_isSaving) return;
              Navigator.of(context).pop(); // Close the dialog without saving
            },
            text: 'Cancel',
            iconData: Icons.cancel,
            color: _isSaving ? Colors.grey : Colors.red,
            textStyle:
                TextStyle(color: _isSaving ? Colors.grey[600] : Colors.white),
            iconColor: _isSaving ? Colors.grey[600] : Colors.white,
          ),
        ];
      },
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
    await ref.watch(authProvider).value!.user!.updatePhotoURL(url);
    ref.watch(appUserNotifierProvider.notifier).updateData({'photoUrl': url});

    return url;
  }
}
