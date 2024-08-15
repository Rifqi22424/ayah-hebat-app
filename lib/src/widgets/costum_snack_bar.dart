import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, Color color) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: color, 
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
