import 'package:ayahhebat/src/widgets/image_cover_builder.dart';
import 'package:flutter/material.dart';

class NewsContentPage extends StatefulWidget {
  const NewsContentPage({super.key});

  @override
  State<NewsContentPage> createState() => _NewsContentPageState();
}

class _NewsContentPageState extends State<NewsContentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // body: Center(
      //   child: Column(
      //     mainAxisSize: MainAxisSize.max,
      //     crossAxisAlignment: CrossAxisAlignment.center,
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Text("Under Maintanance", style: AppStyles.heading2TextStyle),
      //       SizedBox(height: 10),
      //       CircularProgressIndicator(color: AppColors.primaryColor),
      //     ],
      //   ),
      // ),
      body: GestureDetector(
          onTap: () {},
          child: ImageCoverBuilder(imagePath: 'images/news-content.png')),
    );
  }
}
