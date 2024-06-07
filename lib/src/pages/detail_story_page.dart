import 'package:ayahhebat/src/api/kegiatan_api.dart';
import 'package:ayahhebat/src/consts/app_styles.dart';
import 'package:ayahhebat/src/models/kegiatan_model.dart';
import 'package:ayahhebat/src/widgets/video_player_builder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../main.dart';
import '../consts/app_colors.dart';
import '../widgets/app_bar_builder.dart';

class DetailStoryPage extends StatefulWidget {
  final int kegiatanId;
  const DetailStoryPage({super.key, required this.kegiatanId});

  @override
  State<DetailStoryPage> createState() => DetailStoryPageState();
}

class DetailStoryPageState extends State<DetailStoryPage> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarBuilder(
        title: "Story Kegiatan",
        showBackButton: true,
        showCancelButton: false,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: FutureBuilder(
        future: KegiatanApi().getKegiatanById(widget.kegiatanId),
        builder: (context, AsyncSnapshot<Kegiatan> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
              ),
            );
          } else if (!snapshot.hasData) {
            return Center(
              child: const Text('Tidak ada kegiatan ditemukan.'),
            );
          } 
          else if (snapshot.hasError) {
            return Center(
              child: const Text('Tidak ada kegiatan ditemukan.'),
            );
          } else {
            Kegiatan kegiatan = snapshot.data!;
            DateFormat dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');
            String formattedDate =
                dateFormat.format(DateTime.parse(kegiatan.createdAt));
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    kegiatan.title,
                    style: AppStyles.heading2TextStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(formattedDate, style: AppStyles.heading2TextStyle),
                  SizedBox(height: screenHeight * 0.015),
                  allNullFile("${kegiatan.file1}", "${kegiatan.file2}",
                      "${kegiatan.file3}"),
                  mediaContent("${kegiatan.file1}"),
                  mediaContent("${kegiatan.file2}"),
                  mediaContent("${kegiatan.file3}"),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  bool checkVid(String url) {
    return url.endsWith("mp4");
  }

  allNullFile(String path1, String path2, String path3) {
    if (path1.isEmpty && path2.isEmpty && path3.isEmpty) {
      return Column(
        children: [
          const SizedBox(height: 15),
          Container(
            width: 250,
            height: 125,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.grey,
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_not_supported),
                  const SizedBox(width: 5),
                  Text("NO IMAGE AVAILABLE", style: AppStyles.labelTextStyle),
                ],
              ),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget mediaContent(String path) {
    if (path.isEmpty || path == "$serverPath/uploads/") {
      return Container();
    }

    String fullPath = "$serverPath/uploads/$path";

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              child: checkVid(fullPath)
                  ? Container(
                    decoration: const BoxDecoration(
                      color: Colors.black
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InteractiveViewer(child: VideoPlayerBuilder(url: fullPath)),
                      ],
                    ),
                  )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: InteractiveViewer(
                        child: Image.network(
                          fullPath,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
            );
          },
        );
      },
      child: Container(
          width: 400,
          height: 200,
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: checkVid(fullPath) ? null : BorderRadius.circular(8),
            image: checkVid(fullPath)
                ? null
                : DecorationImage(
                    image: NetworkImage(fullPath), fit: BoxFit.cover),
          ),
          child: checkVid(fullPath)
              ? Container(
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.play_circle_fill,
                      size: 50, color: AppColors.whiteColor),
                )
              : const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(
                      Icons.zoom_in_map_outlined,
                      color: AppColors.whiteColor,
                    ),
                  ),
                )),
    );
  }
}
