import 'package:ayahhebat/src/api/announcement_api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../widgets/app_bar_builder.dart';
import 'package:ayahhebat/src/models/announcement_model.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  final AnnouncementApi announcementApi = AnnouncementApi();

  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      await initializeDateFormatting('id_ID', null);
      List<Announcement> announcements =
          await AnnouncementApi().getUserAnnouncements();
      return announcements;
    } catch (e) {
      throw Exception("Error fetching announcements: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBarBuilder(
          title: "Pengumuman",
          showBackButton: true,
          showCancelButton: false,
          onBackButtonPressed: () {
            Navigator.pop(context);
          },
        ),
        body: FutureBuilder(
          future: fetchAnnouncements(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryColor),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Tidak ada data notifikasi'),
              );
            } else if (snapshot.hasData) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final announcement = snapshot.data![index];
                  DateFormat dateFormat = DateFormat('EEEE, d MMMM y', 'id_ID');
                  String formattedDate =
                      dateFormat.format(DateTime.parse(announcement.createdAt));
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, '/detailAnnouncement',
                            arguments: {"announcementId": announcement.id});
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Ink(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              padding: EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.whiteColor,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset('images/speaker.png'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    announcement.title,
                                    style: AppStyles.heading2TextStyle,
                                  ),
                                  Text(
                                    formattedDate,
                                    style: AppStyles.hintTextStyle,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text('Tidak ada data notifikasi'),
              );
            }
          },
        ));
  }
}
