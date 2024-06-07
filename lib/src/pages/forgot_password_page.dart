// ignore_for_file: use_build_context_synchronously

import 'package:ayahhebat/src/api/user_api.dart';
import 'package:flutter/material.dart';
import '../consts/app_colors.dart';
import '../mixins/validation_mixin.dart';
import '../widgets/app_bar_builder.dart';
import '../widgets/button_builder.dart';
import '../widgets/form_builder.dart';
import '../widgets/label_builder.dart';

class ChangePasswordPage extends StatefulWidget {
  final String token;
  const ChangePasswordPage({super.key, required this.token});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with ValidationMixin {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController newConfirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoadingWidget = false;

  _sendNewPassword() async {
    try {
      setState(() {
        isLoadingWidget = true;
      });
      bool sendPass = await UserApi().forgotPassword(
          newConfirmPasswordController.text, newConfirmPasswordController.text, widget.token);
      if (sendPass) {
        Navigator.pushNamed(context, '/login');
        final snackBar = SnackBar(
          content: const Text('Change password success'),
          backgroundColor: AppColors.greenColor,
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
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
            padding: const EdgeInsets.all(15),
            height: screenHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.015),
                const LabelBuilder(text: "Kata Sandi Baru"),
                SizedBox(height: screenHeight * 0.015),
                FormBuilder(
                  hintText: "newPassword",
                  formController: newPasswordController,
                  validator: validateNonNull,
                  isPassword: true,
                  isDescription: false,
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: screenHeight * 0.015),
                const LabelBuilder(text: "Ulang Kata Sandi"),
                SizedBox(height: screenHeight * 0.015),
                FormBuilder(
                  hintText: "ulang newPassword",
                  formController: newConfirmPasswordController,
                  validator: (value) => validateConfirmPassword(
                      value, newPasswordController.text),
                  isPassword: true,
                  isDescription: false,
                  keyboardType: TextInputType.text,
                ),
                const Spacer(),
                ButtonBuilder(
                    isLoadingWidget: isLoadingWidget,
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        _sendNewPassword();
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
