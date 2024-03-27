// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:ayahhebat/src/widgets/nama_kuttab_form_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../api/profile_api.dart';
import '../../consts/app_colors.dart';
import '../../consts/app_styles.dart';
import '../../mixins/validation_mixin.dart';
import '../../utils/shared_preferences.dart';
import '../../widgets/button_builder.dart';
import '../../widgets/form_builder.dart';
import '../../widgets/label_builder.dart';

class AddProfilePage extends StatefulWidget {
  const AddProfilePage({super.key});

  @override
  State<AddProfilePage> createState() => _AddProfilePageState();
}

class _AddProfilePageState extends State<AddProfilePage> with ValidationMixin {
  TextEditingController namaController = TextEditingController();
  TextEditingController istriController = TextEditingController();
  TextEditingController anakController = TextEditingController();
  TextEditingController namaKuttabController = TextEditingController();
  TextEditingController tahunController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedMedia;

  Future<void> _sendProfileData() async {
    SharedPreferencesHelper.getId().then((id) async {

      File? photo;
      if (selectedMedia != null) {
        photo = File(selectedMedia!);
      } else {
        ByteData byteData = await rootBundle.load('images/empty-profile.png');
        List<int> imageData = byteData.buffer.asUint8List();
        Directory tempDir = await getTemporaryDirectory();
        String tempPath = tempDir.path;
        File tempFile = File('$tempPath/empty-profile.png');
        await tempFile.writeAsBytes(imageData);
        photo = tempFile;
      }

      bool success = await ProfileApi().addProfile(
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
        Navigator.pushNamed(context, '/home');
      }
    });
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

  @override
  void initState() {
    super.initState();
    namaKuttabController.text = "Kutab Alfatih Sukabumi";
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('images/ayah-hebat-logo.png',
                          width: 200, height: 80)
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01875),
                  Text("Profile Anda", style: AppStyles.headingTextStyle),
                  SizedBox(height: screenHeight * 0.0075),
                  Text("Mohon isi data profile anda terlebih dahulu",
                      style: AppStyles.hintTextStyle),
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
                              backgroundColor: AppColors.accentColor,
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
                  SizedBox(height: screenHeight * 0.015),
                  const LabelBuilder(text: "Nama Lengkap"),
                  SizedBox(height: screenHeight * 0.015),
                  FormBuilder(
                    hintText: "Jhon Doe",
                    formController: namaController,
                    validator: validateNonNull,
                    isPassword: false,
                    isDescription: false,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: screenHeight * 0.015),
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
                  SizedBox(height: screenHeight * 0.015),
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
                  SizedBox(height: screenHeight * 0.015),
                  const LabelBuilder(text: "Nama Kuttab"),
                  SizedBox(height: screenHeight * 0.015),
                  NamaKuttabForm(
                      formController: namaKuttabController,
                      hintText: "Nama Kuttab",
                      keyboardType: TextInputType.text),
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
                  // Spacer(),
                  SizedBox(height: screenHeight * 0.015),
                  ButtonBuilder(
                      onPressed: () async {
                        if (_formKey.currentState?.validate() ?? false) {
                          try {
                            _sendProfileData();
                          } catch (e) {
                            final snackBar = SnackBar(
                              content: const Text('Invalid email or password'),
                              backgroundColor: AppColors.redColor,
                            );

                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        }
                      },
                      child: const Text("Save"))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
