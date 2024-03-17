import 'package:flutter/material.dart';
import '../consts/app_colors.dart';

class SettingButtonBuilder extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const SettingButtonBuilder(
      {super.key, required this.title, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
            color: AppColors.grey, borderRadius: BorderRadius.circular(60)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16, left: 14),
            child: Text(title),
          )),
          Container(
            height: 35,
            width: 35,
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColors.textColor,
                borderRadius: BorderRadius.circular(60)),
            child: Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          )
        ]),
      ),
    );
  }
}
