import 'dart:typed_data';

import 'package:codecraft/io/file_io.dart';
import 'package:codecraft/io/io.dart';
import 'package:codecraft/io/web_io.dart';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  late Uint8List imageFile = Uint8List(0);
  Io io = kIsWeb ? WebIo() : FileIo();
  bool imageChanged = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    imageUrl = DatabaseHelper().auth.currentUser!.photoURL ?? '';
    user = DatabaseHelper().auth.currentUser;
    displayNameController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    print(imageUrl);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Account'),
      ),
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
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Display Name",
                  prefixIcon: Icon(Icons.person),
                  hintText: 'Enter your name',
                  helperText: 'Leave blank to keep the same name'),
              controller: displayNameController,
            ),
            const SizedBox(height: 60),

            //TODO: do this fr
            // FutureBuilder(
            //   future: Auth(DatabaseHelper().auth).updateUser(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState != ConnectionState.done) {
            //       return LoadingAnimationWidget.dotsTriangle(
            //           color: Colors.white, size: 100);
            //     }

            //     return Container();
            //   },
            // ),
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

  Future<void> updateProfilePicture(
      User? currentUser, Uint8List imageFile) async {
    if (currentUser == null) {
      return;
    }

    try {
      io.uploadImageToStorage(imageFile).then(
        (value) async {
          io.getDownloadUrl(value).then(
            (url) async {
              await currentUser.updatePhotoURL(url);
              setState(() {
                imageUrl = url;
              });
            },
          );
        },
      );
    } catch (error) {
      print("Error updating profile picture: $error");
    }
  }
}
