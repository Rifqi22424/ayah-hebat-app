import 'package:flutter/material.dart';
import '../consts/app_styles.dart';

class AppBarLeftBuilder extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String description;
  final String? imagePath;
  final bool showLeadingButton;
  final VoidCallback? onLeadingButtonTapped;

  const AppBarLeftBuilder(
      {super.key,
      required this.title,
      required this.description,
      this.imagePath,
      this.showLeadingButton = false,
      this.onLeadingButtonTapped});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showLeadingButton
          ? SizedBox(
              width: 50,
              height: 50,
              child: Center(
                child: Image.asset(imagePath!),
              ),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyles.heading2TextStyle,
          ),
          SizedBox(height: 4),
          Text(
            description,
            style: AppStyles.hintTextStyle,
          ),
        ],
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
