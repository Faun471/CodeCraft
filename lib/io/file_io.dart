import 'dart:typed_data';

import 'package:codecraft/io/io.dart';
import 'package:image_picker/image_picker.dart';

class FileIo extends Io {
  @override
  Future<Uint8List> pickImage() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);

    return Future.value(image!.readAsBytes());
  }
}
