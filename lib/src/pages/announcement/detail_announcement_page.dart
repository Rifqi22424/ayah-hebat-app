import 'package:ayahhebat/src/api/announcement_api.dart';
import 'package:ayahhebat/src/consts/app_styles.dart';
import 'package:ayahhebat/src/models/announcement_model.dart';
import 'package:ayahhebat/src/widgets/button_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shimmer/shimmer.dart';

import '../../consts/app_colors.dart';

class DetailAnnouncementPage extends StatefulWidget {
  final int announcementId;
  const DetailAnnouncementPage({super.key, required this.announcementId});

  @override
  State<DetailAnnouncementPage> createState() => _DetailAnnouncementPageState();
}

class _DetailAnnouncementPageState extends State<DetailAnnouncementPage> {
  final AnnouncementApi announcementApi = AnnouncementApi();

  Future<Announcement> fetchAnnouncement() async {
    try {
      await initializeDateFormatting('id_ID', null);
      Announcement announcement =
          await AnnouncementApi().getAnnouncementById(widget.announcementId);
      return announcement;
    } catch (e) {
      throw Exception("Error fetching announcement: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future: fetchAnnouncement(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerEffect();
        } else if (snapshot.hasError) {
          return const Center(
            child: Text('Tidak ada data notifikasi'),
          );
        } else if (snapshot.hasData) {
          final Announcement announcement = snapshot.data!;
          DateFormat dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');
          String formattedDate =
              dateFormat.format(DateTime.parse(announcement.createdAt));
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: NetworkImage(announcement.imageUrl),
                              fit: BoxFit.cover)),
                      height: 500,
                      width: double.maxFinite,
                    ),
                    Positioned(
                        left: 0,
                        top: 0,
                        child: Column(
                          children: [
                            const SizedBox(height: 42),
                            Container(
                              margin: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.grey)),
                              child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: const Icon(
                                    Icons.navigate_before,
                                    color: AppColors.primaryColor,
                                  )),
                            ),
                          ],
                        )),
                    Positioned(
                        left: 0,
                        bottom: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 22, left: 16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                announcement.title,
                                style: AppStyles.heading1WhiteTextStyle,
                                softWrap: true,
                              ),
                              Text(
                                formattedDate,
                                style: AppStyles.heading3WhiteTextStyle,
                              )
                            ],
                          ),
                        ))
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: MarkdownBody(
                    softLineBreak: true,
                    data: announcement.content,
                    styleSheet: MarkdownStyleSheet(
                      textAlign: WrapAlignment.spaceEvenly,
                      h1: AppStyles.heading2TextStyle,
                      h2: AppStyles.labelBoldTextStyle,
                      p: AppStyles.labelTextStyle,
                      listBullet: AppStyles.labelTextStyle,
                      strong: AppStyles.labelBoldTextStyle,
                      img: AppStyles.labelTextStyle,
                    ),
                  ),
                ),
                if (announcement.routes != "/")
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24, horizontal: 16),
                    child: ButtonBuilder(
                        onPressed: () async {
                          Navigator.pushNamed(context, announcement.routes);
                        },
                        child: Text("Pelajari lebih lanjut")),
                  )
              ],
            ),
          );
        }
        return Center(
          child: Text('Tidak ada data notifikasi'),
        );
      },
    ));
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          Container(
            height: 500,
            color: Colors.white,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 20.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 150,
                      height: 20.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 100.0,
                      color: Colors.white,
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      height: 50.0,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
