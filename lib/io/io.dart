import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class Io {
  Future<String> uploadImageToStorage(Uint8List image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference storageReference = FirebaseStorage.instance.ref().child(
        '${FirebaseAuth.instance.currentUser!.email!}/profile_pictures/$fileName');

    await storageReference.putData(
        image, SettableMetadata(contentType: 'image/jpeg'));

    return fileName;
  }

  Future<String> getDownloadUrl(String fileName) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(
        '${FirebaseAuth.instance.currentUser!.email!}/profile_pictures/$fileName');

    String downloadUrl = '';

    await storageReference.getDownloadURL().then((value) {
      downloadUrl = value;
    });

    return downloadUrl;
  }

  Future<dynamic> pickImage();
}
