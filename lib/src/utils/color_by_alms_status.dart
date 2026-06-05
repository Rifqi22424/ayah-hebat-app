import 'package:flutter/material.dart';

import '../consts/app_colors.dart';

class ColorByAlmsStatus {
  static Color getColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.greenColor;
      case 'pending':
        return AppColors.primaryColor;
      case 'failed':
        return AppColors.redColor;
      default:
        return AppColors.primaryColor;
    }
  }

  static Color getBackgroundColor(String status) {
    switch (status) {
      case 'success':
        return AppColors.lightGreenColor;
      case 'pending':
        return AppColors.lightPrimaryColor;
      case 'failed':
        return AppColors.lightRedColor;
      default:
        return AppColors.lightPrimaryColor;
    }
  }
}
