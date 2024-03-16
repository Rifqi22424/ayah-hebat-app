import 'package:ayahhebat/src/api/user_api.dart';
import 'package:flutter/material.dart';
import '../consts/app_colors.dart';
import '../mixins/validation_mixin.dart';
import '../utils/shared_preferences.dart';
import '../widgets/app_bar_builder.dart';
import '../widgets/button_builder.dart';
import '../widgets/form_builder.dart';
import '../widgets/label_builder.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with ValidationMixin {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newConfirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _sendNewPassword() async {
    String? email = await SharedPreferencesHelper.getEmail();
    bool sendPass = await UserApi().changePassword(
        email!,
        oldPasswordController.text,
        newConfirmPasswordController.text,
        newConfirmPasswordController.text);

    final snackBar = SnackBar(
      content:
          Text(sendPass ? 'Change password success' : 'Change password failed'),
      backgroundColor: sendPass ? AppColors.greenColor : AppColors.redColor,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (sendPass) {
      Navigator.pop(context);
      SharedPreferencesHelper.savePassword(newPasswordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBarBuilder(
        title: "Ubah Kata Sandi",
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
            padding: EdgeInsets.all(15),
            height: screenHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.015),
                LabelBuilder(text: "Kata Sandi Lama"),
                SizedBox(height: screenHeight * 0.015),
                FormBuilder(
                  hintText: "oldpassword",
                  formController: oldPasswordController,
                  validator: validateNonNull,
                  isPassword: false,
                  isDescription: false,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: screenHeight * 0.015),
                LabelBuilder(text: "Kata Sandi Baru"),
                SizedBox(height: screenHeight * 0.015),
                FormBuilder(
                  hintText: "newPassword",
                  formController: newPasswordController,
                  validator: validateNonNull,
                  isPassword: false,
                  isDescription: false,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: screenHeight * 0.015),
                LabelBuilder(text: "Ulang Kata Sandi"),
                SizedBox(height: screenHeight * 0.015),
                FormBuilder(
                  hintText: "ulangsandi",
                  formController: newConfirmPasswordController,
                  validator: validateNonNull,
                  isPassword: false,
                  isDescription: false,
                  keyboardType: TextInputType.text,
                ),
                Spacer(),
                ButtonBuilder(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        try {
                          _sendNewPassword();

                          print("Login berhasil");
                        } catch (e) {
                          final snackBar = SnackBar(
                            content: Text('Invalid email or password'),
                            backgroundColor: AppColors.redColor,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                          print("Gagal login: $e");
                        }
                      }
                    },
                    child: Text("Save"))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
