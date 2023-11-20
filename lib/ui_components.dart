import 'package:flutter/material.dart';

SnackBar getSnackbar(String snackBarMessage) {
  return SnackBar(
    width: 150.0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20.0)),
    ),
    backgroundColor: const Color.fromARGB(255, 221, 221, 221),
    padding: const EdgeInsets.all(7.0),
    content: Align(
      alignment: Alignment.center,
      child: Text(
        snackBarMessage,
        style: const TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
      ),
    ),
    duration: const Duration(seconds: 1, milliseconds: 500),
    behavior: SnackBarBehavior.floating,
  );
}
