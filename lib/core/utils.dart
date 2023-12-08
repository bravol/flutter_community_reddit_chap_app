import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_community_redit_chat_app/responsive/responsive.dart';

//show snack bar in case of error or success message
void showSuccessSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Responsive(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
}

//show snack bar in case of error or success message
void showErrorSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange,
        content: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
}

//pick image
Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);
  return image;
}
