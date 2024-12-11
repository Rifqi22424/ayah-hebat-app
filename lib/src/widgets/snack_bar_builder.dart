import 'package:flutter/material.dart';

import '../consts/app_colors.dart';

void showCostumSnackBar({
  required BuildContext context,
  required String message,
  Color backgroundColor = AppColors.textColor,
}) {
  final snackBar = SnackBar(
    content: Text(message),
    backgroundColor: backgroundColor,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
