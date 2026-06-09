import 'package:flutter/material.dart';
import '../consts/app_colors.dart';

class SettingButtonBuilder extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  final Color? bgColor;
  final Color? textColor;
  final Color? buttonColor;
  final Color? arrowColor;
  

  const SettingButtonBuilder(
      {super.key, required this.title, required this.onPressed, this.bgColor, this.textColor, this.buttonColor, this.arrowColor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        decoration: BoxDecoration(
            color: bgColor ?? AppColors.grey, borderRadius: BorderRadius.circular(60)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 16, left: 14),
            child: Text(title, style: TextStyle(color: textColor),),
          )),
          Container(
            height: 35,
            width: 35,
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: buttonColor ?? AppColors.textColor,
                borderRadius: BorderRadius.circular(60)),
            child: Icon(
              Icons.arrow_forward,
              color: arrowColor ?? Colors.white,
            ),
          )
        ]),
      ),
    );
  }
}
