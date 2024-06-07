import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SnackBarBuilder extends StatelessWidget {
  String message;
  Color? color;
  SnackBarBuilder({super.key, required this.message, required this.color});

  @override
  Widget build(BuildContext context) {
    return SnackBar(
      content: Text(message),
      backgroundColor: color,
    );
  }
}
