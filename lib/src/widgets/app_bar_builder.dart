import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';

class AppBarBuilder extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showCancelButton;
  final VoidCallback? onBackButtonPressed;
  final VoidCallback? onCancelButtonPressed;

  const AppBarBuilder(
      {super.key,
      required this.title,
      this.showBackButton = false,
      this.showCancelButton = false,
      this.onBackButtonPressed,
      this.onCancelButtonPressed});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppStyles.heading2TextStyle,
      ),
      elevation: 0,
      centerTitle: true,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.grey)),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: onBackButtonPressed ?? () {},
                  icon: const Icon(
                    Icons.navigate_before,
                    color: AppColors.primaryColor,
                  )),
            )
          : null,
      actions: showCancelButton
          ? [
              Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.grey)),
                child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: onCancelButtonPressed ?? () {},
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textColor,
                    )),
              )
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
