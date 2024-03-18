import 'package:flutter/material.dart';

import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../widgets/app_bar_builder.dart';

class StoryActivitiesPage extends StatelessWidget {
  const StoryActivitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarBuilder(
        title: "Story Kegiatan",
        showBackButton: true,
        showCancelButton: true,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
        onCancelButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Under Maintanance", style: AppStyles.heading2TextStyle),
            SizedBox(height: 10),
            SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
