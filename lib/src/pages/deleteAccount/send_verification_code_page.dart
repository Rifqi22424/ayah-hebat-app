import 'dart:convert';

import 'package:ayahhebat/src/utils/shared_preferences.dart';
import 'package:ayahhebat/src/widgets/button_builder.dart';
import 'package:ayahhebat/src/widgets/costum_snack_bar.dart';
import 'package:flutter/material.dart';

import '../../api/user_api.dart';
import '../../consts/app_styles.dart';

class SendVerificationCodePage extends StatefulWidget {
  const SendVerificationCodePage({super.key});

  @override
  State<SendVerificationCodePage> createState() =>
      _SendVerificationCodePageState();
}

class _SendVerificationCodePageState extends State<SendVerificationCodePage> {
  String email = "Loading..";
  UserApi userService = UserApi();

  _loadEmail() async {
    String? prefs = await SharedPreferencesHelper.getEmail();

    setState(() {
      email = prefs!;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text("Verifikasi Akun", style: AppStyles.headingTextStyle),
          SizedBox(height: 24),
          Image.asset(
            "images/messenger.png",
            width: 100,
            height: 100,
          ),
          SizedBox(height: 24),
          Text(
            "Kami akan mengirim kode verifikasi \nmelalui email anda.",
            style: AppStyles.hintTextStyle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
          Text(
            email,
            style: AppStyles.labelTextStyle,
          ),
          SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ButtonBuilder(
                onPressed: () async {
                  try {
                    bool sendVerifCode =
                        await userService.sendDeleteAccountVerification(email);
                    if (sendVerifCode) {
                      print("cek");
                      showCustomSnackBar(
                        context,
                        "Kode verifikasi telah terkirim, \nmohon untuk mengecek gmail anda",
                        Colors.green,
                      );
                      Navigator.pushNamed(context, '/inputVerificationCode',
                          arguments: {"email": email});
                    }
                    print('ceks');
                  } catch (e) {
                    String errorMessage;

                    try {
                      final decodedJson = jsonDecode(e.toString());
                      errorMessage =
                          decodedJson['error'] ?? "An error occurred";
                    } catch (jsonError) {
                      // If the error is not in JSON format
                      errorMessage = e.toString();
                    }

                    showCustomSnackBar(context, errorMessage, Colors.red);
                    print(errorMessage);
                  }
                },
                child: Text("Kirim Kode")),
          ),
        ],
      ),
    );
  }
}
