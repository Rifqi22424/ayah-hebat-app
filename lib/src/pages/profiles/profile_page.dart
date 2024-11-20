import 'package:url_launcher/url_launcher.dart';

import '../../utils/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../../main.dart';
import '../../api/profile_api.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../widgets/app_bar_builder.dart';
import '../../widgets/setting_button_builder.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController istriController = TextEditingController();
  TextEditingController anakController = TextEditingController();
  TextEditingController namaKuttabController = TextEditingController();
  TextEditingController tahunController = TextEditingController();

  String nama = "";
  String poin = "";
  String bio = "";
  String linkImage = "";

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    ProfileApi().getUserNProfile().then((user) {
      setState(() {
        istriController.text = user.profile.namaIstri;
        anakController.text = user.profile.namaAnak;
        namaKuttabController.text = user.profile.namaKuttab;
        tahunController.text = user.profile.tahunMasukKuttab.toString();
        nama = user.profile.nama;
        poin = user.totalScoreMonth.toString();
        bio = user.profile.bio;
        linkImage = user.profile.photo;
      });
    }).catchError((error) {});
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: const AppBarBuilder(title: "Profile"),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: RefreshIndicator(
          color: AppColors.primaryColor,
          onRefresh: _fetchUserProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.grey,
                      radius: 30,
                      backgroundImage:
                          NetworkImage("$serverPath/uploads/$linkImage"),
                    ),
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nama, style: AppStyles.heading2TextStyle),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: AppColors.yellowAccent),
                              child: Row(
                                children: [
                                  Image.asset('images/trophy.png',
                                      height: 20, width: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    '$poin Point',
                                    style: AppStyles.heading3PrimaryTextStyle,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            // InkWell(
                            //   borderRadius: BorderRadius.circular(24),
                            //   onTap: () {
                            //     Navigator.pushNamed(context, '/ranking');
                            //   },
                            //   child: Row(
                            //     children: [
                            //       Text(
                            //         "Lihat ranking",
                            //         style: AppStyles.heading3PrimaryTextStyle,
                            //       ),
                            //       const Icon(
                            //         Icons.navigate_next_sharp,
                            //         color: AppColors.primaryColor,
                            //       )
                            //     ],
                            //   ),
                            // )
                          ],
                        )
                      ],
                    )
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  bio,
                  style: AppStyles.hintTextStyle,
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Nama Istri",
                            style: AppStyles.mediumTextStyle,
                          ),
                          SizedBox(height: screenHeight * 0.0125),
                          TextFormField(
                            controller: istriController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "",
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.blueColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              hintStyle: AppStyles.hintTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Nama Anak", style: AppStyles.mediumTextStyle),
                          SizedBox(height: screenHeight * 0.0125),
                          TextFormField(
                            controller: anakController,
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: "",
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: AppColors.blueColor,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(32),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              hintStyle: AppStyles.hintTextStyle,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(height: screenHeight * 0.0125),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nama Kuttab",
                      style: AppStyles.mediumTextStyle,
                    ),
                    SizedBox(height: screenHeight * 0.0125),
                    TextFormField(
                      controller: namaKuttabController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "",
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.blueColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        hintStyle: AppStyles.hintTextStyle,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.0125),
                    Text(
                      "Tahun Ajaran Anak",
                      style: AppStyles.mediumTextStyle,
                    ),
                    SizedBox(height: screenHeight * 0.0125),
                    TextFormField(
                      controller: tahunController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "",
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.blueColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(32),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        hintStyle: AppStyles.hintTextStyle,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Text("Setting", style: AppStyles.heading2TextStyle),
                SizedBox(height: screenHeight * 0.03),
                SettingButtonBuilder(
                  title: "Edit profile",
                  onPressed: () {
                    Navigator.pushNamed(context, '/editProfile');
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                SettingButtonBuilder(
                  title: "Ubah password",
                  onPressed: () {
                    Navigator.pushNamed(context, '/changePassword');
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                SettingButtonBuilder(
                  title: "Ajukan hapus akun",
                  onPressed: () {
                    // Navigator.pushNamed(context, '/changePassword');
                    showAlertDialog(context, "hapusAkun");
                  },
                ),
                SizedBox(height: screenHeight * 0.02),
                SettingButtonBuilder(
                  title: "Log out",
                  onPressed: () {
                    showAlertDialog(context, "logOut");
                  },
                )
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "btnSupport",
        onPressed: _launchURL,
        child: Icon(Icons.support_agent),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<dynamic> showAlertDialog(BuildContext context, String type) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        if (type == "logOut") {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Peringatan', style: AppStyles.mediumTextStyle),
            content: Text('Apakah anda yakin ingin keluar?',
                style: AppStyles.heading3TextStyle),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.blueColor,
                  disabledForegroundColor: AppColors.halfBlueColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tidak'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.redColor,
                  disabledForegroundColor: AppColors.halfRedColor,
                ),
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                  SharedPreferencesHelper.saveToken("");
                  SharedPreferencesHelper.saveId(0);
                  SharedPreferencesHelper.saveEmail("");
                  SharedPreferencesHelper.savePassword("");
                },
                child: const Text('Ya'),
              ),
            ],
          );
        } else if (type == "hapusAkun") {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text('Peringatan', style: AppStyles.mediumTextStyle),
            content: Text('Apakah anda yakin ingin menghapus akun anda?',
                style: AppStyles.heading3TextStyle),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.blueColor,
                  disabledForegroundColor: AppColors.halfBlueColor,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Tidak'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.redColor,
                  disabledForegroundColor: AppColors.halfRedColor,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/sendVerificationCode");
                },
                child: const Text('Ya'),
              ),
            ],
          );
        } else {
          return Container();
        }
      },
    );
  }

  void _launchURL() async {
    final url = Uri.parse('https://wa.me/6281936242236');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
