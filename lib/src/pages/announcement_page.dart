import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Under Maintanance", style: AppStyles.heading2TextStyle),
            SizedBox(height: 10),
            CircularProgressIndicator(color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }
}
