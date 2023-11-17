import 'package:flutter/material.dart';

//show snack bar in case of error or success message
void showSuccessSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          text,
          style: const TextStyle(color: Colors.white),
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
