import 'package:codecraft/io/io.dart';
import 'package:file_picker/file_picker.dart';

class WebIo extends Io {
  @override
  Future<dynamic> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    return Future.value(result!.files.single.bytes);
  }
}
