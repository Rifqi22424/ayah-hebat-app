import 'package:flutter/material.dart';

import '../consts/app_styles.dart';

class LabelBuilder extends StatelessWidget {
  final String text;

  const LabelBuilder({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppStyles.labelTextStyle,
    );
  }
}
