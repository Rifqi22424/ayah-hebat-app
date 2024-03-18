import 'dart:io';
import 'package:flutter/material.dart';
import '../../main.dart';
import '../api/kegiatan_api.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../models/user_profile_model.dart';
import '../utils/shared_preferences.dart';
import '../widgets/image_cover_builder.dart';

import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../widgets/video_player_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController descController = TextEditingController();
  List<String> selectedMedia = [];
  int timeIndex = 1;
  List<UserProfile> topUsers = [];
  bool loadingUpload = false;

  Future<void> _pickVidMedia() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    final f = File(result!.files.first.path!);
    int sizeInBytes = f.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > 10) {
      _showMaxMediaAlert("Batas Ukuran Tercapai",
          "Anda mengupload file yang lebih dari 10 mb");
    } else if (result.files.isNotEmpty) {
      setState(() {
        selectedMedia.add(result.files.first.path!);
      });
    }
  }

  Future<void> _pickImageMedia(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    var maxFileSizeInBytes = 10 * 1048576;
    var imagePath = await pickedFile!.readAsBytes();
    var fileSize = imagePath.length;

    if (maxFileSizeInBytes <= fileSize) {
      _showMaxMediaAlert("Batas Ukuran Tercapai",
          "Anda mengupload file yang lebih dari 10 mb");
    } else {
      setState(() {
        selectedMedia.add(pickedFile.path);
      });
    }
  }

  // Future<void> _pickAudioMedia() async {
  //   FilePickerResult? result =
  //       await FilePicker.platform.pickFiles(type: FileType.audio);

  //   if (result != null && result.files.isNotEmpty) {
  //     setState(() {
  //       selectedMedia.add(result.files.first.path!);
  //     });
  //   }
  // }

  Future<void> _sendKegiatanData() async {
    if (descController.text.isEmpty) {
      final snackBar = SnackBar(
        content: Text('Nama Kegiatan tidak boleh kosong'),
        backgroundColor: AppColors.accentColor,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    String title = descController.text;

    SharedPreferencesHelper.getId().then((id) async {
      String userId = id.toString();
      print(userId);

      File? file1 = selectedMedia.isNotEmpty ? File(selectedMedia[0]) : null;
      File? file2 = selectedMedia.length > 1 ? File(selectedMedia[1]) : null;
      File? file3 = selectedMedia.length > 2 ? File(selectedMedia[2]) : null;
      print("$file1, $file2, $file3");

      setState(() {
        loadingUpload = true;
      });

      bool success =
          await KegiatanApi().postKegiatan(title, userId, file1, file2, file3);

      final snackBar = SnackBar(
        content: Text(success
            ? 'Kegiatan data posted successfully'
            : 'Failed to post kegiatan data'),
        backgroundColor: success ? AppColors.greenColor : AppColors.redColor,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);

      if (success) {
        descController.clear();
        setState(() {
          loadingUpload = false;
          selectedMedia.clear();
        });
      } else {
        loadingUpload = false;
      }
    });
  }

  void _showMaxMediaAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, style: AppStyles.mediumTextStyle),
          content: Text(message, style: AppStyles.heading3TextStyle),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  rankingContainer(
      {required double height,
      required String num,
      required String image,
      required String name,
      required String poin}) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    String shortName = name.length > 10 ? "${name.substring(0, 10)}.." : name;

    return Column(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.accentColor,
          radius: 40,
          backgroundImage: NetworkImage('$serverPath/uploads/$image'),
        ),
        SizedBox(height: screenHeight * 0.00625),
        Text(shortName, style: AppStyles.heading2TextStyle),
        SizedBox(height: screenHeight * 0.00625),
        Row(
          children: [
            Image.asset('images/trophy.png', height: 20),
            Text(
              poin,
              style: AppStyles.hintTextStyle,
            ),
            Text(" Point", style: AppStyles.hintTextStyle),
          ],
        ),
        SizedBox(height: screenHeight * 0.00625),
        Container(
          padding: EdgeInsets.only(top: 15),
          height: height,
          width: screenWidth * 0.26,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage('images/ranking-container.png'))),
          alignment: Alignment.topCenter,
          child: Text(
            num,
            style: AppStyles.heading2WhiteTextStyle,
          ),
        ),
      ],
    );
  }

  String textActive() {
    if (timeIndex == 0) {
      return "Daily";
    } else if (timeIndex == 1) {
      return "Monthly";
    } else {
      return "Ever";
    }
  }

  void _changeTimeIndex(int newIndex) {
    setState(() {
      timeIndex = newIndex;
      _fetchTopUsers();
    });
  }

  MainAxisAlignment _changeAlignment() {
    if (timeIndex == 0) {
      return MainAxisAlignment.start;
    } else if (timeIndex == 1) {
      return MainAxisAlignment.center;
    } else {
      return MainAxisAlignment.end;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTopUsers();
  }

  Future<void> _fetchTopUsers() async {
    try {
      String? token = await SharedPreferencesHelper.getToken();
      String timePeriod = _getTimePeriod();
      List<UserProfile> users =
          await KegiatanApi().getTopUsers(timePeriod, token!);
      print(timePeriod);
      print(token);
      print("fethcingg");
      setState(() {
        topUsers = users;
      });
    } catch (e) {
      print('Error fetching top users: $e');
    }
  }

  String _getTimePeriod() {
    if (timeIndex == 0) {
      return "day";
    } else if (timeIndex == 1) {
      return "month";
    } else {
      return "year";
    }
  }

  _getScoreTimePeriod(int index) {
    if (timeIndex == 0) {
      return topUsers[index].totalScoreDay.toString();
    } else if (timeIndex == 1) {
      return topUsers[index].totalScoreMonth.toString();
    } else {
      return topUsers[index].totalScoreYear.toString();
    }
  }

  mediaTypeWidget(String selectedMedia) {
    if (selectedMedia.endsWith('.mp4')) {
      return VideoPlayerWidget(videoPath: selectedMedia);
    }
    // else if (selectedMedia.endsWith('.mp3') ||
    //     selectedMedia.endsWith('.m4a')) {
    //   return AudioPlayerWidget(audioPath: selectedMedia);
    // }

    else if (selectedMedia.endsWith('.jpg') ||
        selectedMedia.endsWith('.png') ||
        selectedMedia.endsWith('.jpeg')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.file(
          File(selectedMedia),
          fit: BoxFit.cover,
        ),
      );
    } else {
      _showMaxMediaAlert("Type File Tidak Valid",
          "Kirimkan file yang sesuai, jpg, png, jpeg, mp4, mp3 atau m4a");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight,
      width: screenWidth,
      child: Stack(
        children: [
          ImageCoverBuilder(imagePath: 'images/home-bg.png'),
          Container(
            padding: EdgeInsets.only(
                top: screenHeight * 0.0625, left: 15, right: 15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Ayah Hebat", style: AppStyles.headingTextStyle),
                        SizedBox(height: screenHeight * 0.005),
                        Text("Dokumentasikan kegiatan ayah dan keluarga",
                            style: AppStyles.hintTextStyle),
                      ],
                    ),
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        Navigator.pushNamed(context, '/announcement');
                      },
                      child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.grey)),
                          child: Image.asset('images/speaker.png',
                              width: 25, height: 25)),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                Center(
                  child: Container(
                      width: 350,
                      height: 50,
                      decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(40)),
                      child: Stack(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _changeTimeIndex(0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Daily",
                                        style: AppStyles.labelTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _changeTimeIndex(1),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Monthly",
                                        style: AppStyles.labelTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _changeTimeIndex(2),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Ever",
                                        style: AppStyles.labelTextStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: _changeAlignment(),
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 100,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(40),
                                    ),
                                    child: Center(
                                      child: Text(
                                        textActive(),
                                        style: AppStyles.heading3WhiteTextStyle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        ],
                      )),
                ),
              ],
            ),
          ),
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (topUsers.isNotEmpty && topUsers.length > 1)
                        rankingContainer(
                          poin: _getScoreTimePeriod(1),
                          name: topUsers[1].profile.nama,
                          height: screenHeight * 0.1,
                          num: "2",
                          image: topUsers[1].profile.photo,
                        ),
                      SizedBox(width: 10),
                      if (topUsers.isNotEmpty && topUsers.length > 0)
                        rankingContainer(
                          poin: _getScoreTimePeriod(0),
                          name: topUsers[0].profile.nama,
                          height: screenHeight * 0.125,
                          num: "1",
                          image: topUsers[0].profile.photo,
                        ),
                      SizedBox(width: 10),
                      if (topUsers.isNotEmpty && topUsers.length > 2)
                        rankingContainer(
                          poin: _getScoreTimePeriod(2),
                          name: topUsers[2].profile.nama,
                          height: screenHeight * 0.075,
                          num: "3",
                          image: topUsers[2].profile.photo,
                        ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 15, bottom: 10, left: 10, right: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(24),
                            topLeft: Radius.circular(24)),
                        color: AppColors.textColor),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                "Tambahkan Kegiatan",
                                style: AppStyles.heading2WhiteTextStyle,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, '/story');
                                },
                                child: Row(
                                  children: [
                                    Image.asset("images/time.png",
                                        width: 20, height: 20),
                                    SizedBox(width: 5),
                                    Text(
                                      "Story kegiatan",
                                      style: AppStyles.heading3WhiteTextStyle,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (selectedMedia.length == 3) {
                              _showMaxMediaAlert("Batas Media Terpilih",
                                  "Anda sudah mencapai batas maksimal media yang dapat dipilih.");
                            } else {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.photo),
                                        title: Text('Pilih Foto'),
                                        onTap: () {
                                          _pickImageMedia(ImageSource.gallery);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.videocam),
                                        title: Text('Pilih Video'),
                                        onTap: () {
                                          _pickVidMedia();
                                          Navigator.pop(context);
                                        },
                                      ),
                                      // ListTile(
                                      //   leading: Icon(Icons.audio_file),
                                      //   title: Text('Pilih Audio'),
                                      //   onTap: () {
                                      //     _pickAudioMedia();
                                      //     Navigator.pop(context);
                                      //   },
                                      // ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                top: 10, right: 10, left: 10, bottom: 15),
                            height: screenHeight * 0.25,
                            decoration: BoxDecoration(
                              color: AppColors.white10Color,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Visibility(
                              visible: selectedMedia.isEmpty,
                              child: Stack(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset("images/add-button.png",
                                              height: 50),
                                          SizedBox(height: 10),
                                          Text(
                                            "Upload Foto atau Video",
                                            style: AppStyles.hintTextStyle,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 5, right: 5),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              replacement: Stack(
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          for (int index = 0;
                                              index < selectedMedia.length;
                                              index++)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  selectedMedia.removeAt(index);
                                                });
                                              },
                                              child: Stack(
                                                children: [
                                                  SizedBox(
                                                    height: 100,
                                                    width: 100,
                                                    child: mediaTypeWidget(
                                                        selectedMedia[index]),
                                                  ),
                                                  Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: Icon(
                                                        Icons.cancel,
                                                        color: AppColors
                                                            .whiteColor,
                                                      ))
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            "Upload lagi",
                                            style: AppStyles.hintTextStyle,
                                          ),
                                          SizedBox(width: 5),
                                          Image.asset("images/add-button.png",
                                              height: 18),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 5, right: 5),
                                      child: Icon(
                                        Icons.info_outline,
                                        color: AppColors.whiteColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius:
                                            BorderRadius.circular(24)),
                                    hintText: "Nama kegiatan keluargamu",
                                    filled: true,
                                    fillColor: AppColors.whiteColor,
                                    suffixIcon: InkWell(
                                      onTap: () {
                                        _showDropdown(context);
                                      },
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColors.textColor,
                                      ),
                                    )),
                                controller: descController,
                              ),
                            ),
                            SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                _sendKegiatanData();
                              },
                              child: Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: AppColors.primaryColor),
                                child: loadingUpload
                                    ? Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.send,
                                        color: AppColors.whiteColor,
                                      ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }

  void _showDropdown(BuildContext context) {
    List<String> options = [
      'Sajarah (Satu jam bersama ayah)',
      'Diari (Dialog iman sekali sehari)',
      'MasaIyah (Magrib sampai Isya ditemanI ayah)',
      'Berkisah'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Pilih Nama Kegiatan',
            style: AppStyles.mediumTextStyle,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (BuildContext context, int index) {
                final option = options[index];
                return ListTile(
                  title: Text(
                    option,
                    style: AppStyles.heading3TextStyle,
                  ),
                  onTap: () {
                    setState(() {
                      descController.text = option;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
