import 'package:flutter/material.dart';

class ImageCoverBuilder extends StatelessWidget {
  final String imagePath;

  const ImageCoverBuilder({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
      )),
    );
  }
}
