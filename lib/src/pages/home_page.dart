// ignore_for_file: use_build_context_synchronously

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
import 'package:image/image.dart' as img;

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
  bool isInfoVisible = false;

  Future<void> _pickVidMedia() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);

    if (result == null) return;

    final f = File(result.files.first.path!);
    int sizeInBytes = f.lengthSync();
    double sizeInMb = sizeInBytes / (1024 * 1024);
    if (sizeInMb > 20) {
      _showMaxMediaAlert("Batas Ukuran Tercapai",
          "Anda mengupload file yang lebih dari 20 mb");
    } else if (selectedMedia.any((media) => media.endsWith('.mp4'))) {
      _showMaxMediaAlert("Batas Upload Video Tercapai",
          "Anda mengupload file video lebih dari 1");
    } else if (result.files.isNotEmpty) {
      setState(() {
        selectedMedia.add(result.files.first.path!);
      });
    }
  }

  Future<void> _pickImageMedia(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile == null) return;

    var imagePath = File(pickedFile.path);
    var fileSize = await imagePath.length();

    if (fileSize > 5 * 1048576) {
      img.Image image = img.decodeImage(await imagePath.readAsBytes())!;
      var compressedImage = img.encodeJpg(image, quality: 85);
      await imagePath.writeAsBytes(compressedImage);
    }

    setState(() {
      selectedMedia.add(pickedFile.path);
    });
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
      const snackBar = SnackBar(
        content: Text('Nama Kegiatan tidak boleh kosong'),
        backgroundColor: AppColors.accentColor,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    String title = descController.text;

    SharedPreferencesHelper.getId().then((id) async {
      String userId = id.toString();

      File? file1 = selectedMedia.isNotEmpty ? File(selectedMedia[0]) : null;
      File? file2 = selectedMedia.length > 1 ? File(selectedMedia[1]) : null;
      File? file3 = selectedMedia.length > 2 ? File(selectedMedia[2]) : null;

      setState(() {
        loadingUpload = true;
      });

      try {
        bool success = await KegiatanApi()
            .postKegiatan(title, userId, file1, file2, file3);

        if (success) {
          descController.clear();
          setState(() {
            loadingUpload = false;
            selectedMedia.clear();
          });

          _fetchTopUsers();

          final snackBar = SnackBar(
            content: const Text('Kegiatan data posted successfully'),
            backgroundColor: AppColors.greenColor,
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          setState(() {
            loadingUpload = false;
          });
        }
      } catch (e) {
        setState(() {
          loadingUpload = false;
        });
        String errorString = e.toString();
        String errorMessage = errorString
            .split(":")[2]
            .replaceAll('"', '')
            .replaceAll('}', '')
            .trim();
        final snackBar = SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.redColor,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
              child: const Text('OK'),
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
          backgroundColor: AppColors.grey,
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
          padding: const EdgeInsets.only(top: 15),
          height: height,
          width: screenWidth * 0.26,
          decoration: const BoxDecoration(
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

  Alignment _changeAlignment() {
    switch (timeIndex) {
      case 0:
        return Alignment.centerLeft;
      case 1:
        return Alignment.center;
      case 2:
        return Alignment.centerRight;
      default:
        return Alignment.centerLeft;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTopUsers();
  }

  Future<void> _fetchTopUsers() async {
    String? token = await SharedPreferencesHelper.getToken();
    String timePeriod = _getTimePeriod();
    List<UserProfile> users =
        await KegiatanApi().getTopUsers(timePeriod, token!);
    setState(() {
      topUsers = users;
    });
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
      return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: VideoPlayerWidget(videoPath: selectedMedia));
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

  void onInfoTap() {
    isInfoVisible = !isInfoVisible;
    setState(() {});
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
          const ImageCoverBuilder(imagePath: 'images/home-bg.png'),
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
                    Row(
                      children: [
                        Material(
                          shape: CircleBorder(),
                          color: AppColors.primaryColor,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () {
                              Navigator.pushNamed(context, '/faq');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                // border: Border.all(
                                //     color: const Color.fromRGBO(
                                //         233, 233, 233, 1))
                              ),
                              child: const Icon(
                                Icons.question_mark,
                                size: 20,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3),
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            Navigator.pushNamed(context, '/announcement');
                          },
                          child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.grey)),
                              child: Image.asset('images/speaker.png',
                                  width: 20, height: 20)),
                        ),
                      ],
                    )
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
                          AnimatedAlign(
                              alignment: _changeAlignment(),
                              duration: const Duration(milliseconds: 300),
                              child: Container(
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
                              ))
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
                  if (topUsers.isEmpty)
                    SizedBox(
                        height: screenHeight * 0.075,
                        child:
                            const Center(child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryColor),
                              ),
                            ))),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (topUsers.isNotEmpty && topUsers.length > 1)
                        rankingContainer(
                          poin: _getScoreTimePeriod(1),
                          name: topUsers[1].profile.nama,
                          height: screenHeight * 0.075,
                          num: "2",
                          image: topUsers[1].profile.photo,
                        ),
                      const SizedBox(width: 10),
                      if (topUsers.isNotEmpty && topUsers.length > 0)
                        rankingContainer(
                          poin: _getScoreTimePeriod(0),
                          name: topUsers[0].profile.nama,
                          height: screenHeight * 0.1,
                          num: "1",
                          image: topUsers[0].profile.photo,
                        ),
                      const SizedBox(width: 10),
                      if (topUsers.isNotEmpty && topUsers.length > 2)
                        rankingContainer(
                          poin: _getScoreTimePeriod(2),
                          name: topUsers[2].profile.nama,
                          height: screenHeight * 0.05,
                          num: "3",
                          image: topUsers[2].profile.photo,
                        ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 10, left: 10, right: 10),
                    decoration: const BoxDecoration(
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
                                    const SizedBox(width: 5),
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
                                        leading: const Icon(Icons.photo),
                                        title: const Text('Pilih Foto'),
                                        onTap: () {
                                          _pickImageMedia(ImageSource.gallery);
                                          Navigator.pop(context);
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.videocam),
                                        title: const Text('Pilih Video'),
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
                            margin: const EdgeInsets.only(
                                top: 10, right: 10, left: 10, bottom: 15),
                            height: screenHeight * 0.25,
                            decoration: BoxDecoration(
                              color: AppColors.white10Color,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Visibility(
                              visible: selectedMedia.isEmpty,
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
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      selectedMedia
                                                          .removeAt(index);
                                                    });
                                                  },
                                                  child: Stack(
                                                    children: [
                                                      SizedBox(
                                                        height: 100,
                                                        width: 100,
                                                        child: mediaTypeWidget(
                                                            selectedMedia[
                                                                index]),
                                                      ),
                                                      const Positioned(
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
                                                SizedBox(width: 10)
                                              ],
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Text(
                                            "Upload lagi",
                                            style: AppStyles.hintTextStyle,
                                          ),
                                          const SizedBox(width: 5),
                                          Image.asset("images/add-button.png",
                                              height: 18),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Positioned(
                                  //   bottom: 0,
                                  //   right: 0,
                                  //   child: IconButton(
                                  //     onPressed: onInfoTap,
                                  //     icon: Icon(Icons.info_outline),
                                  //     color: AppColors.whiteColor,
                                  //   ),
                                  // ),
                                ],
                              ),
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
                                          const SizedBox(height: 10),
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        if (isInfoVisible == true)
                                          InkWell(
                                            onTap: onInfoTap,
                                            child: Container(
                                              margin: EdgeInsets.only(right: 5),
                                              padding: const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 12,
                                                  left: 12,
                                                  right: 12),
                                              decoration: const BoxDecoration(
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          "images/message_container.png"),
                                                      fit: BoxFit.fill)),
                                              child: const Text(
                                                "Bukti foto atau video \nkegiatan yang dilakukan \nbersama anak anda",
                                                style: TextStyle(
                                                    color:
                                                        AppColors.whiteColor),
                                              ),
                                            ),
                                          ),
                                        IconButton(
                                          onPressed: onInfoTap,
                                          icon: Icon(Icons.info_outline),
                                          color: AppColors.whiteColor,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 10),
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
                                      child: const Icon(
                                        Icons.arrow_drop_down,
                                        color: AppColors.textColor,
                                      ),
                                    )),
                                controller: descController,
                              ),
                            ),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () {
                                _sendKegiatanData();
                              },
                              child: Container(
                                height: 55,
                                width: 55,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    color: AppColors.primaryColor),
                                child: loadingUpload
                                    ? const Center(
                                        child: SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                                AppColors.primaryColor),
                                          ),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send,
                                        color: AppColors.whiteColor,
                                      ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
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
