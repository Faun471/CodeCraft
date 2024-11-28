import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codecraft/io/file_io.dart';
import 'package:codecraft/io/io.dart';
import 'package:codecraft/io/web_io.dart';
import 'package:codecraft/models/app_user.dart';
import 'package:codecraft/models/app_user_notifier.dart';
import 'package:codecraft/models/organisation.dart';
import 'package:codecraft/screens/apprentice/organisation/join_organisation.dart';
import 'package:codecraft/screens/apprentice/organisation/organisation_card.dart';
import 'package:codecraft/services/auth/auth_helper.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:codecraft/utils/theme_utils.dart';
import 'package:codecraft/utils/utils.dart';
import 'package:codecraft/widgets/buttons/custom_text_fields.dart';
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
    final userData = ref.read(appUserNotifierProvider).value!;
    displayNameController = TextEditingController(text: userData.displayName);
    phoneNumberController = TextEditingController(text: userData.phoneNumber);
    firstNameController = TextEditingController(text: userData.firstName);
    miController = TextEditingController(text: userData.mi);
    lastNameController = TextEditingController(text: userData.lastName);
    suffixController = TextEditingController(text: userData.suffix);
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
            Text('User Profile',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            _buildUserCard(appUserState),
            const SizedBox(height: 20),
            _buildOrganizationDetailsCard(appUserState),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(AsyncValue<AppUser> appUserState) {
    return UserCard(
      userName: appUserState.value!.displayName ?? 'No Name',
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
                              imageFile = (await Utils.pickImage(context))!;
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
                  CustomTextField(
                    labelText: 'Display Name',
                    icon: Icons.person,
                    controller: displayNameController,
                    mode: ValidationMode.none,
                    textInputAction: TextInputAction.next,
                  ),
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
                    initialValue: PhoneNumber(dialCode: "+63", isoCode: "PH"),
                    textFieldController: phoneNumberController,
                    keyboardAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '* This field is required';
                      }

                      if (value.length != 12) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                    hintText: 'Phone Number',
                    autofillHints: const [AutofillHints.telephoneNumber],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomTextField(
                          labelText: 'First Name',
                          icon: Icons.person,
                          controller: firstNameController,
                          mode: ValidationMode.none,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: CustomTextField(
                          labelText: 'MI',
                          controller: miController,
                          mode: ValidationMode.none,
                          textInputAction: TextInputAction.next,
                          isRequired: false,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CustomTextField(
                          labelText: 'Last Name',
                          icon: Icons.person,
                          controller: lastNameController,
                          mode: ValidationMode.none,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: CustomTextField(
                          labelText: 'Suffix',
                          controller: suffixController,
                          mode: ValidationMode.none,
                          textInputAction: TextInputAction.next,
                          isRequired: false,
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
          IconsButton(
            onPressed: () {
              if (_isSaving) return;
              Navigator.of(context).pop();
            },
            text: 'Cancel',
            iconData: Icons.cancel,
            color: _isSaving ? Colors.grey : Colors.red,
            textStyle:
                TextStyle(color: _isSaving ? Colors.grey[600] : Colors.white),
            iconColor: _isSaving ? Colors.grey[600] : Colors.white,
          ),
          const SizedBox(width: 10),
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

  Widget _buildOrganizationDetailsCard(AsyncValue<AppUser> appUserState) {
    return Card(
      surfaceTintColor: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: StreamBuilder<DocumentSnapshot>(
            stream: DatabaseHelper()
                .organizations
                .doc(appUserState.requireValue.orgId!)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  height: 200,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: JoinOrganization(),
                );
              }

              final orgData = snapshot.data!.data() as Map<String, dynamic>;
              return OrganizationCard(
                organization: Organization.fromMap(orgData),
              );
            },
          ),
        ),
      ),
    );
  }
}
