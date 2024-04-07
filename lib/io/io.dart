import 'dart:typed_data';

import 'package:codecraft/services/database_helper.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class Io {
  Future<String> uploadImageToStorage(Uint8List image) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();

    Reference storageReference = FirebaseStorage.instance.ref().child(
        '${DatabaseHelper().auth.currentUser!.email!}/profile_pictures/$fileName');

    UploadTask uploadTask = storageReference.putData(
        image, SettableMetadata(contentType: 'image/jpeg'));

    await uploadTask.whenComplete(() => print('Image uploaded'));

    return fileName;
  }

  Future<String> getDownloadUrl(String fileName) async {
    Reference storageReference = FirebaseStorage.instance.ref().child(
        '${DatabaseHelper().auth.currentUser!.email!}/profile_pictures/$fileName');

    String downloadUrl = await storageReference.getDownloadURL();

    return downloadUrl;
  }

  Future<dynamic> pickImage();
}
