import 'package:flutter/material.dart';
import 'package:petagonv0_flutter/main.dart';

class utils {
  static showSnackBar(String? text) {
    if (text == null) return;

    final snackbar = SnackBar(
      content: Text(text),
      backgroundColor: Colors.red,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackbar);
  }
}
