import 'package:flutter/material.dart';

import '../consts/app_colors.dart';

class LogoBuilder extends StatelessWidget {
  final String image;
  final VoidCallback onTap;

  const LogoBuilder({super.key, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accentColor, width: 1),
        ),
        child: Image.asset(
          image,
        ),
      ),
    );
  }
}
