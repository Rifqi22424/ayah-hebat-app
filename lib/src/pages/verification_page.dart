import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../api/auth_api.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  _VerificationPageState createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  // final TextEditingController _verificationCodeController =
  //     TextEditingController();
  AuthApi authApi = AuthApi();
  List<String> verificationValues = List.filled(6, '');

  @override
  void initState() {
    super.initState();
    // _verificationCodeController.addListener(checkVerificationCode);
  }

  void checkVerificationCode() {
    final String verificationCode = verificationValues.join();

    // final String verificationCode = _verificationCodeController.text;

    print(verificationCode.length);
    if (verificationCode.length == 6) {
      submitVerification();
    }
  }

  void submitVerification() async {
    // final String verificationCode = _verificationCodeController.text;

    final String verificationCode = verificationValues.join();

    bool verificationResult =
        await authApi.verify(widget.email, verificationCode);

    if (verificationResult) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Verification Successful'),
            content: Text('Verification successful!'),
          );
        },
      );
      Navigator.pushNamed(context, "/login");
      final snackBar = SnackBar(
        content: Text("Verification Successful"),
        backgroundColor: AppColors.greenColor,
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Verification Failed'),
            content: Text('Verification failed. Please try again.'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Masukkan Kode", style: AppStyles.headingTextStyle),
            SizedBox(height: screenHeight * 0.01875),
            Text(
              "Kode verifikasi telah dikirimkan melalui email Anda, Mohon periksa email Anda.",
              style: AppStyles.hintTextStyle,
            ),
            SizedBox(height: screenHeight * 0.0625),
            // TextFormField(
            //   controller: _verificationCodeController,
            //   maxLength: 6,
            // ),
            SizedBox(
              height: 50,
              width: 270,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: SizedBox(
                      width: 40,
                      child: TextField(
                        // controller: TextEditingController.fromValue(
                        //   TextEditingValue(
                        //     text:
                        //         _verificationCodeController.text.length > index
                        //             ? _verificationCodeController.text[index]
                        //             : '',
                        //     selection: TextSelection.collapsed(
                        //       offset: _verificationCodeController.text.length,
                        //     ),
                        //   ),
                        // ),
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(), counterText: ""),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                          verificationValues[index] = value;
                          print(verificationValues);
                          print(verificationValues.join());
                          checkVerificationCode();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.03125),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                      text: "Tidak mendapatkan kode? ",
                      style: AppStyles.labelTextStyle),
                  TextSpan(
                    text: "Kirim ulang",
                    style: AppStyles.heading3PrimaryTextStyle,
                    recognizer: TapGestureRecognizer()..onTap = () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
