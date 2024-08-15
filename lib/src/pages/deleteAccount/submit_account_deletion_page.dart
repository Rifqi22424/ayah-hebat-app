import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../consts/app_styles.dart';

class SubmitAccountDeletionPage extends StatefulWidget {
  const SubmitAccountDeletionPage({super.key});

  @override
  State<SubmitAccountDeletionPage> createState() =>
      _SubmitAccountDeletionPageState();
}

class _SubmitAccountDeletionPageState extends State<SubmitAccountDeletionPage> {
  bool isAgree = false;

  @override
  Widget build(BuildContext context) {
    final tsf = MediaQuery.of(context).textScaler;

    return Scaffold(
      body: Column(
        children: [
          Text("Alasan"),
          TextField(
            maxLines: 5,
            decoration: InputDecoration.collapsed(
                hintText:
                    "Masukan alasan mengapa anda ingin menghapus akun anda? "),
          ),
          Text("Alamat Email Kamu"),
          TextField(
            decoration: InputDecoration.collapsed(
                hintText:
                    "Lengkapi alamat email agar kami dapat menghubungi kamu"),
          ),
          Row(
            children: [
              Checkbox(
                value: isAgree,
                onChanged: (newValue) {
                  setState(() {
                    isAgree = newValue!;
                  });
                },
              ),
              RichText(
                  textScaler: tsf,
                  text: TextSpan(children: [
                    TextSpan(
                        text: "Tidak mendapatkan kode? ",
                        style: AppStyles.hintTextStyle),
                    TextSpan(
                        text: "Kirim ulang",
                        style: AppStyles.labelTextStyle,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            print("tes");
                          }),
                  ])),
            ],
          )
        ],
      ),
    );
  }
}
