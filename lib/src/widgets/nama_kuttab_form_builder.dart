import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';

class NamaKuttabForm extends StatelessWidget {
  final TextEditingController formController;
  final String hintText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const NamaKuttabForm({
    Key? key,
    required this.formController,
    required this.hintText,
    required this.keyboardType,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: formController,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: AppColors.blueColor,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(32),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        hintStyle: AppStyles.hintTextStyle,
        errorStyle: AppStyles.heading3RedTextStyle,
      ),
      readOnly: true,
      style: AppStyles.labelTextStyle,
      validator: validator,
    );
  }
}