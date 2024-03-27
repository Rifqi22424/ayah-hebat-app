// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:ayahhebat/main.dart';
import 'package:ayahhebat/src/widgets/nama_kuttab_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/profile_api.dart';
import '../../consts/app_colors.dart';
import '../../mixins/validation_mixin.dart';
import '../../widgets/app_bar_builder.dart';
import '../../widgets/button_builder.dart';
import '../../widgets/form_builder.dart';
import '../../widgets/label_builder.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with ValidationMixin {
  TextEditingController namaController = TextEditingController();
  TextEditingController istriController = TextEditingController();
  TextEditingController anakController = TextEditingController();
  TextEditingController namaKuttabController = TextEditingController();
  TextEditingController tahunController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedMedia;
  String? selectedMediaEmpty;
  bool isLoadingWidget = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    downloadLocalPhoto();
  }

  _fetchUserProfile() {
    ProfileApi().getUserNProfile().then((user) {
      setState(() {
        namaController.text = user.profile.nama;
        istriController.text = user.profile.namaIstri;
        anakController.text = user.profile.namaAnak;
        namaKuttabController.text = user.profile.namaKuttab;
        tahunController.text = user.profile.tahunMasukKuttab.toString();
        bioController.text = user.profile.bio;
        downloadImageAndSaveLocally(user.profile.photo);
      });
    }).catchError((error) {});
  }

  Future<void> _sendProfileData() async {
    setState(() {
      isLoadingWidget = true;
    });
    File? photo = selectedMedia != null
        ? File(selectedMedia!)
        : File(selectedMediaEmpty!);

    bool success = await ProfileApi().editProfile(
        namaController.text,
        bioController.text,
        namaKuttabController.text,
        tahunController.text,
        istriController.text,
        anakController.text,
        photo);

    final snackBar = SnackBar(
      content: Text(success
          ? 'Profile data posted successfully'
          : 'Failed to post profile data'),
      backgroundColor: success ? AppColors.greenColor : AppColors.redColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (success) {
      Navigator.pop(context);
    }
  }

  _removeProfilePhoto() {
    setState(() {
      selectedMedia = null;
    });
  }

  Future<void> _pickImageMedia(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        selectedMedia = pickedFile.path;
      });
    }
  }

  downloadLocalPhoto() async {
    ByteData byteData = await rootBundle.load('images/empty-profile.png');
    List<int> imageData = byteData.buffer.asUint8List();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File tempFile = File('$tempPath/empty-profile.png');
    await tempFile.writeAsBytes(imageData);
    selectedMediaEmpty = tempFile.path;
  }

  Future<void> downloadImageAndSaveLocally(String linkImage) async {
    String imageUrl = '$serverPath/uploads/$linkImage';
    final http.Client client = http.Client();

    try {
      final http.Response response = await client.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/profile_image.png');
        await file.writeAsBytes(response.bodyBytes);
        if (mounted) {
          setState(() {
            selectedMedia = file.path;
          });
        }
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      ByteData byteData = await rootBundle.load('images/empty-profile.png');
      List<int> imageData = byteData.buffer.asUint8List();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      File tempFile = File('$tempPath/empty-profile.png');
      await tempFile.writeAsBytes(imageData);
      selectedMediaEmpty = tempFile.path;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to load image. Using default image.'),
          backgroundColor: AppColors.redColor,
        ),
      );
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarBuilder(
        title: "Profile Anda",
        showBackButton: true,
        showCancelButton: true,
        onBackButtonPressed: () {
          Navigator.pop(context);
        },
        onCancelButtonPressed: () {
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(15),
            height: screenHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: screenHeight * 0.01875),
                // Text("Profile Anda", style: AppStyles.headingTextStyle),
                // SizedBox(height: screenHeight * 0.0075),
                // Text("Mohon isi data dengan teliti dan benar",
                //     style: AppStyles.hintTextStyle),
                SizedBox(height: screenHeight * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                (selectedMedia != null)
                                    ? ListTile(
                                        leading: const Icon(Icons.delete),
                                        title: const Text('Hapus Profile'),
                                        onTap: () {
                                          _removeProfilePhoto();
                                          Navigator.pop(context);
                                        },
                                      )
                                    : Container(),
                                ListTile(
                                  leading: const Icon(Icons.photo),
                                  title: const Text('Pilih Foto'),
                                  onTap: () {
                                    _pickImageMedia(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.grey,
                            radius: 45,
                            child: selectedMedia != null
                                ? ClipOval(
                                    child: Image.file(
                                    File(selectedMedia!),
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ))
                                : Image.asset(
                                    'images/empty-profile.png',
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryColor),
                              child: const Icon(
                                Icons.camera_alt,
                                color: AppColors.textColor,
                                size: 20,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const LabelBuilder(text: "Nama Lengkap"),
                SizedBox(height: screenHeight * 0.015),
                FormBuilder(
                  hintText: "asep",
                  formController: namaController,
                  validator: validateNonNull,
                  isPassword: false,
                  isDescription: false,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: screenHeight * 0.015),
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LabelBuilder(text: "Nama Istri"),
                        SizedBox(height: screenHeight * 0.015),
                        FormBuilder(
                          hintText: "Aisyah",
                          formController: istriController,
                          validator: validateNonNull,
                          isPassword: false,
                          isDescription: false,
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 25),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LabelBuilder(text: "Nama Anak"),
                        SizedBox(height: screenHeight * 0.015),
                        FormBuilder(
                          hintText: "Ujang",
                          formController: anakController,
                          validator: validateNonNull,
                          isPassword: false,
                          isDescription: false,
                          keyboardType: TextInputType.text,
                        ),
                      ],
                    ),
                  )
                ]),
                SizedBox(height: screenHeight * 0.015),
                const LabelBuilder(text: "Tahun Masuk Kuttab"),
                SizedBox(height: screenHeight * 0.015),
                FormBuilder(
                  hintText: "2022",
                  formController: tahunController,
                  validator: validateTahun,
                  isPassword: false,
                  isDescription: false,
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: screenHeight * 0.015),
                const LabelBuilder(text: "Nama Kuttab"),
                SizedBox(height: screenHeight * 0.015),
                NamaKuttabForm(
                    formController: namaKuttabController,
                    hintText: "nama kuttab",
                    keyboardType: TextInputType.text),
                SizedBox(height: screenHeight * 0.015),
                const LabelBuilder(text: "Biodata"),
                SizedBox(height: screenHeight * 0.015),
                FormBuilder(
                  hintText:
                      "Seorang pengusaha yang bersemangat, ayah dari dua anak, dan ingin memastikan bahwa keluarganya hidup dalam lingkungan yang penuh dengan nilai-nilai Islami.",
                  formController: bioController,
                  validator: validateNonNull,
                  isPassword: false,
                  isDescription: true,
                  keyboardType: TextInputType.text,
                ),
                const Spacer(),
                SizedBox(height: screenHeight * 0.015),
                ButtonBuilder(
                    isLoadingWidget: isLoadingWidget,
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        _sendProfileData();
                      }
                    },
                    child: const Text("Save"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
