import 'package:ayahhebat/src/api/kegiatan_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../consts/app_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../consts/app_styles.dart';
import '../models/kegiatan_model.dart';
import '../widgets/app_bar_builder.dart';

class StoryPage extends StatelessWidget {
  const StoryPage({super.key});

  Future<List<Kegiatan>> fetchKegiatans() async {
    try {
      await initializeDateFormatting('id_ID', null);
      List<Kegiatan> kegiatans = await KegiatanApi().getKegiatanByUserId();
      return kegiatans;
    } catch (e) {
      throw Exception("Error fetching kegiatans: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: FutureBuilder<List<Kegiatan>>(
        future: fetchKegiatans(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                    )));
          } else if (snapshot.hasError) {
            return const Center(child: Text("Tidak ada data kegiatan"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Tidak ada data kegiatan"));
          } else {
            List<Kegiatan> kegiatansUser = snapshot.data!;
            return ListView.builder(
              itemCount: kegiatansUser.length,
              itemBuilder: (context, index) {
                Kegiatan kegiatan = kegiatansUser[index];
                DateFormat dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');
                String formattedDate =
                    dateFormat.format(DateTime.parse(kegiatan.createdAt));
                return ListTile(
                  title: Text(
                    kegiatan.title,
                    style: AppStyles.labelBoldTextStyle,
                  ),
                  subtitle: Text(
                    formattedDate,
                    style: AppStyles.heading3TextStyle,
                  ),
                  trailing: kegiatan.file1 != "" && kegiatan.file1!.isNotEmpty
                      ?
                      // kegiatan.file1!.endsWith("mp4")
                      // ?
                      Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: AppColors.darkYellow),
                          child: const Center(
                            child: Icon(
                              Icons.video_collection_outlined,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        )
                      // :
                      // ClipRRect(
                      //     borderRadius: BorderRadius.circular(8),
                      //     child: Image.network(
                      //       '$serverPath/uploads/${kegiatan.file1}',
                      //       height: 100,
                      //       width: 100,
                      //       fit: BoxFit.cover,
                      //     ),
                      //   )
                      : SizedBox.shrink(),
                  onTap: () {
                    if (kegiatan.file1 != "" && kegiatan.file1!.isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        '/detailStory',
                        arguments: {'kegiatanId': kegiatan.id},
                      );
                    } else {
                      Navigator.pushNamed(context, '/detailStory',
                          arguments: {'kegiatanId': kegiatan.id});
                      ;
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
