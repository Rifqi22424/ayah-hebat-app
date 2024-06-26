// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../mixins/validation_mixin.dart';
import '../utils/shared_preferences.dart';
import '../widgets/button_builder.dart';
import '../widgets/form_builder.dart';
import '../widgets/label_builder.dart';

class RegistPage extends StatefulWidget {
  const RegistPage({super.key});

  @override
  State<RegistPage> createState() => _RegistPageState();
}

class _RegistPageState extends State<RegistPage> with ValidationMixin {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthApi authApi = AuthApi();

  showFeatureNotWorking(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('Fitur belum tersedia', style: AppStyles.mediumTextStyle),
          content:
              Text('Mohon untuk lakukan login/ registrasi secara langsung', style: AppStyles.heading3TextStyle,),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.0875),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/ayah-hebat-logo.png',
                      width: 200, height: 80),
                ],
              ),
              SizedBox(height: screenHeight * 0.025),
              Text("Buat akun", style: AppStyles.headingTextStyle),
              SizedBox(height: screenHeight * 0.00625),
              Text(
                  "Selamat datang! Mulailah mendokumentasikan kegiatan keluarga dengan nilai-nilai yang bermakna.",
                  style: AppStyles.hintTextStyle),
              SizedBox(height: screenHeight * 0.05625),
              const LabelBuilder(text: "Username"),
              SizedBox(height: screenHeight * 0.015),
              FormBuilder(
                hintText: "Masukan Username",
                formController: usernameController,
                validator: validateNonNull,
                isPassword: false,
                isDescription: false,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: screenHeight * 0.015),
              const LabelBuilder(text: "Alamat Gmail"),
              SizedBox(height: screenHeight * 0.015),
              FormBuilder(
                hintText: "Masukan Gmail",
                formController: emailController,
                validator: validateEmail,
                isPassword: false,
                isDescription: false,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: screenHeight * 0.015),
              const LabelBuilder(text: "Kata Sandi"),
              SizedBox(height: screenHeight * 0.015),
              FormBuilder(
                hintText: "Masukan Password",
                formController: passwordController,
                validator: validatePassword,
                isPassword: true,
                isDescription: false,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: screenHeight * 0.015),
              const LabelBuilder(text: "Ulang Kata Sandi"),
              SizedBox(height: screenHeight * 0.015),
              FormBuilder(
                hintText: "Masukan Ulang Password",
                formController: confirmPasswordController,
                validator: (value) =>
                    validateConfirmPassword(value, passwordController.text),
                isPassword: true,
                isDescription: false,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: screenHeight * 0.015),
              ButtonBuilder(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      try {
                        bool registResponse = await authApi.register(
                          usernameController.text,
                          emailController.text,
                          passwordController.text,
                          confirmPasswordController.text,
                        );
                        if (registResponse) {
                          SharedPreferencesHelper.saveEmail(
                              emailController.text);
                          SharedPreferencesHelper.savePassword(
                              passwordController.text);
                          Navigator.pushNamed(context, '/verification',
                              arguments: {
                                'email': emailController.text,
                              });
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
                  },
                  child: const Text("Regist")),
              SizedBox(height: screenHeight * 0.01875),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.accentColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("Atau", style: AppStyles.heading3TextStyle),
                  ),
                  const Expanded(child: Divider(color: AppColors.accentColor)),
                ],
              ),
              // SizedBox(height: screenHeight * 0.025),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     LogoBuilder(
              //         onTap: () {
              //           showFeatureNotWorking(context);
              //         },
              //         image: 'images/google-logo.png'),
              //     const SizedBox(width: 10),
              //     LogoBuilder(
              //         onTap: () {
              //           showFeatureNotWorking(context);
              //         },
              //         image: 'images/facebook-logo.png'),
              //     const SizedBox(width: 10),
              //     LogoBuilder(
              //         onTap: () {
              //           showFeatureNotWorking(context);
              //         },
              //         image: 'images/x-logo.png'),
              //   ],
              // ),
              SizedBox(height: screenHeight * 0.05625),
              alreadyHaveAcc(context: context),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    ));
  }

  alreadyHaveAcc({required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: "Sudah punya akun? ", style: AppStyles.labelTextStyle),
              TextSpan(
                text: "Masuk",
                style: AppStyles.heading3PrimaryTextStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, '/login');
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
