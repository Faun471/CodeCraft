// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:codecraft/providers/theme_provider.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_widget/image_picker_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:provider/provider.dart';

class AccountEdit extends StatefulWidget {
  const AccountEdit({super.key});

  @override
  AccountEditState createState() => AccountEditState();
}

class AccountEditState extends State<AccountEdit> {
  late String imageUrl;
  late User? user;
  late TextEditingController displayNameController;
  late File imageFile;
  bool imageChanged = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    imageUrl = DatabaseHelper().auth.currentUser!.photoURL ?? '';
    imageFile = File(imageUrl);
    user = DatabaseHelper().auth.currentUser;
    displayNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ImagePickerWidget(
              diameter: 100,
              initialImage: imageUrl,
              shouldCrop: true,
              isEditable: true,
              iconAlignment: AlignmentDirectional.bottomEnd
                ..add(const Alignment(0.0, 5)),
              fit: BoxFit.cover,
              modalOptions: ModalOptions(
                title: Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 12),
                  child: AutoSizeText(
                    'Select Image Source',
                    maxFontSize: 24,
                    minFontSize: 18,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                cameraText: AutoSizeText(
                  'Camera',
                  maxFontSize: 18,
                  minFontSize: 14,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                galleryText: AutoSizeText(
                  'Gallery',
                  maxFontSize: 18,
                  minFontSize: 14,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                cameraColor: Provider.of<ThemeProvider>(context, listen: false)
                    .preferredColor,
                galleryColor: Provider.of<ThemeProvider>(context, listen: false)
                    .preferredColor,
              ),
              imagePickerOptions:
                  ImagePickerOptions(preferredCameraDevice: CameraDevice.front),
              onChange: (file) async {
                imageUrl = file.path;
                imageFile = file;

                setState(() {
                  imageUrl = file.path;
                  imageFile = file;
                  imageChanged = true;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Display Name",
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Enter your name',
                  helperText: 'Leave blank to keep the same name'),
              controller: displayNameController,
            ),
            const SizedBox(height: 60),
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

                      if (displayNameController.text != user!.displayName &&
                          displayNameController.text.isNotEmpty) {
                        await DatabaseHelper()
                            .auth
                            .currentUser!
                            .updateDisplayName(displayNameController.text);
                      }

                      if (imageChanged) {
                        await updateProfilePicture(user!, imageFile);
                      }

                      displayNameController.clear();
                      imageChanged = false;
                      await user!.reload();

                      Dialogs.materialDialog(
                        context: context,
                        lottieBuilder: Lottie.asset(
                          'assets/anim/congrats.json',
                          repeat: false,
                          height: 100,
                          width: 100,
                          fit: BoxFit.contain,
                        ),
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

  Future<void> updateProfilePicture(User? currentUser, File file) async {
    FirebaseStorage firebaseStorage = FirebaseStorage.instance;
    var storageRef = firebaseStorage.ref(
        '${currentUser!.email!}/profilePicture/${file.path.split('/').last}');

    // Upload the file to Firebase Storage
    UploadTask task = storageRef.putFile(file);

    // Listen for changes in the upload task
    task.snapshotEvents.listen(
      (TaskSnapshot snapshot) async {
        if (snapshot.state == TaskState.success) {
          // If the upload is complete, update the user's photoURL
          String downloadURL = await snapshot.ref.getDownloadURL();
          await DatabaseHelper().auth.currentUser!.updatePhotoURL(downloadURL);
        }
      },
    );

    await currentUser.reload();
  }
}
