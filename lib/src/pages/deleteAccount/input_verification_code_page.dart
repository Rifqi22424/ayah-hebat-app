import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';

import '../../api/user_api.dart';
import "../../consts/app_styles.dart";
import 'package:flutter/material.dart';

import '../../utils/shared_preferences.dart';
import '../../widgets/button_builder.dart';
import '../../widgets/costum_snack_bar.dart';

class InputVerificationCodePage extends StatefulWidget {
  final String email;
  const InputVerificationCodePage({super.key, required this.email});

  @override
  State<InputVerificationCodePage> createState() =>
      InputVerificationCodePageState();
}

class InputVerificationCodePageState extends State<InputVerificationCodePage> {
  bool _onEditing = true;
  String? _code;
  UserApi userService = UserApi();

  String? selectedOption;
  TextEditingController passwordController = TextEditingController();

  final List<String> options = [
    'Tidak Lagi Diperlukan',
    'Pengalaman Buruk',
    'Email atau Notifikasi Berlebihan',
    'Ketidakpercayaan',
  ];

  bool isAgree = false;

  @override
  Widget build(BuildContext context) {
    final tsf = MediaQuery.of(context).textScaler;

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Masukan Kode", style: AppStyles.headingTextStyle),
            SizedBox(height: 14),
            Text(
              "Kode verifikasi telah dikirimkan melalui \nemail Anda, Mohon periksa email Anda.",
              style: AppStyles.hintTextStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 55),
            VerificationCode(
              keyboardType: TextInputType.number,
              textStyle: AppStyles.labelTextStyle,
              underlineColor: Colors.blue,
              length: 6,
              cursorColor: Colors.black,
              margin: const EdgeInsets.all(4),
              fullBorder: true,
              onCompleted: (String value) async {
                setState(() {
                  _code = value;
                });
                print(_code);
                // try {
                //   userService.sendVerifyAccount(widget.email, _code!);
                // } catch (e) {

                // }
                try {
                  bool verifCode =
                      await userService.sendVerifyAccount(widget.email, _code!);
                  if (verifCode) {
                    showCustomSnackBar(
                        context, "Verifikasi berhasil", Colors.green);
                    showConfirmationDialog(context);
                  }
                  print('ceks');
                } catch (e) {
                  String errorMessage;

                  try {
                    final decodedJson = jsonDecode(e.toString());
                    errorMessage = decodedJson['error'] ?? "An error occurred";
                  } catch (jsonError) {
                    errorMessage = e.toString();
                  }

                  showCustomSnackBar(context, errorMessage, Colors.red);
                  print(errorMessage);
                }
              },
              onEditing: (bool value) {
                setState(() {
                  _onEditing = value;
                });
                if (!_onEditing) FocusScope.of(context).unfocus();
              },
            ),
            SizedBox(height: 24),
            RichText(
                textScaler: tsf,
                text: TextSpan(children: [
                  TextSpan(
                      text: "Tidak mendapatkan kode? ",
                      style: AppStyles.hintTextStyle),
                  TextSpan(
                      text: "Kirim ulang",
                      style: AppStyles.bodyPrimaryTextStyle,
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          await resendVerificationFunc(context);
                          // showReasonsDeleteAccount(context);
                          showConfirmationDialog(context);
                        }),
                ])),
            // SizedBox(height: 75),
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
            //   child: ButtonBuilder(
            //       onPressed: () async {
            //         print("object");
            //         // Navigator.pushNamed(context, '/submitAccountDeletion');
            //         showConfirmationDialog(context);
            //       },
            //       child: Text("Kirim Kode")),
            // )
          ],
        ),
      ),
    );
  }

  Future<void> resendVerificationFunc(BuildContext context) async {
    try {
      bool sendVerifCode =
          await userService.resendDeleteAccountVerification(widget.email);
      if (sendVerifCode) {
        print("cek");
        showCustomSnackBar(
          context,
          "Kode verifikasi telah terkirim, \nmohon untuk mengecek gmail anda",
          Colors.green,
        );
        // Navigator.pushNamed(
        //     context, '/inputVerificationCode',
        //     arguments: {"email": email});
      }
      print('ceks');
    } catch (e) {
      String errorMessage;

      try {
        final decodedJson = jsonDecode(e.toString());
        errorMessage = decodedJson['error'] ?? "An error occurred";
      } catch (jsonError) {
        // If the error is not in JSON format
        errorMessage = e.toString();
      }

      showCustomSnackBar(context, errorMessage, Colors.red);
      print(errorMessage);
    }
  }

  Future<dynamic> showConfirmationDialog(BuildContext context) {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PopScope(
          // canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Dialog(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/profile', (route) => false);
                            },
                            icon: Icon(Icons.close))),
                    Image.asset('images/check-icon.png', width: 150),
                    SizedBox(height: 24),
                    Text("Akun Terverifikasi", style: AppStyles.headingTextStyle),
                    SizedBox(height: 16),
                    Text(
                      "Akun Anda telah berhasil diverifikasi, \nSilahkan untuk mengisi data selanjutnya.",
                      style: AppStyles.hintTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ButtonBuilder(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          showReasonsDeleteAccount(context);
                        },
                        child: Text("Selanjutnya")),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<dynamic> showReasonsDeleteAccount(BuildContext context) {
    final tsf = MediaQuery.of(context).textScaler;

    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PopScope(
          // canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: StatefulBuilder(
              builder: (context, setState) => Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image.asset('images/check-icon.png', width: 150),
                      // SizedBox(height: 24),
                      Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/profile', (route) => false);
                              },
                              icon: Icon(Icons.close))),
                      Text("Alasan Penghapusan Akun",
                          style: AppStyles.headingTextStyle),
                      SizedBox(height: 16),
                      Text(
                        "Password Akun ${widget.email}",
                        style: AppStyles.labelTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      TextField(
                        controller: passwordController,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Alasan",
                        style: AppStyles.labelTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: DropdownButton<String>(
                          hint: Text('Select an option'),
                          value: selectedOption,
                          items: options.map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedOption = value;
                            });
                          },
                          isExpanded: true,
                        ),
                      ),
                      Row(children: [
                        Checkbox(
                          value: isAgree,
                          onChanged: (newValue) {
                            setState(() {
                              isAgree = newValue!;
                            });
                          },
                        ),
                        Flexible(
                          child: RichText(
                              textScaler: tsf,
                              text: TextSpan(children: [
                                TextSpan(
                                    text: "Saya setuju dengan ",
                                    style: AppStyles.hintTextStyle),
                                TextSpan(
                                    text: "Syarat & Ketentuan ",
                                    style: AppStyles.labelTextStyle,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        print("tes");
                                      }),
                                TextSpan(
                                    text: "Penghapusan akun",
                                    style: AppStyles.hintTextStyle),
                              ])),
                        ),
                      ]),
                      SizedBox(height: 24),
                      ButtonBuilder(
                          onPressed: () async {
                            await onDeleteAccountPressed(
                                context, passwordController.text, isAgree);
                          },
                          child: Text("Hapus Permanen")),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> onDeleteAccountPressed(
      BuildContext context, String password, bool isAgree) async {
    try {
      if (password.isEmpty || isAgree == false || selectedOption!.isEmpty) {
        showCustomSnackBar(context, "Isi data terlebih dahulu", Colors.red);
      } else {
        bool sendVerifCode = await userService.deleteAccount(
            widget.email, passwordController.text, selectedOption!);
        if (sendVerifCode) {
          print("cek");
          showCustomSnackBar(
            context,
            "Akun anda telah terhapus",
            Colors.red,
          );
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
          SharedPreferencesHelper.saveToken("");
          SharedPreferencesHelper.saveId(0);
          SharedPreferencesHelper.saveEmail("");
          SharedPreferencesHelper.savePassword("");
        }
        print('ceks');
      }
    } catch (e) {
      String errorMessage;

      try {
        final decodedJson = jsonDecode(e.toString());
        errorMessage = decodedJson['error'] ?? "An error occurred";
      } catch (jsonError) {
        // If the error is not in JSON format
        errorMessage = e.toString();
      }

      showCustomSnackBar(context, errorMessage, Colors.red);
      print(errorMessage);
    }
  }
}
