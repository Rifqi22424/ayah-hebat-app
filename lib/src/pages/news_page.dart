import 'package:flutter/material.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  String linkImage = 'images/news.png';

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
            const SizedBox(height: 10),
            const SizedBox(
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
      // body: GestureDetector(
      //     onTap: () {

      //       setState(() {
      //         Navigator.pushNamed(context, '/newsContent');
      //       });
      //     },
      //     child: ImageCoverBuilder(imagePath: 'images/news.png')),
    );
  }
}
