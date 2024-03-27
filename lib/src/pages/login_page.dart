// ignore_for_file: use_build_context_synchronously

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../consts/app_colors.dart';
import '../consts/app_styles.dart';
import '../mixins/validation_mixin.dart';
import '../models/login_response_model.dart';
import '../utils/shared_preferences.dart';
import '../widgets/button_builder.dart';
import '../widgets/form_builder.dart';
import '../widgets/label_builder.dart';
import '../widgets/logo_builder.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ValidationMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AuthApi authApi = AuthApi();

  @override
  void initState() {
    super.initState();
    SharedPreferencesHelper.getEmail().then((email) {
      if (email != null) {
        emailController.text = email;
      }
    });

    SharedPreferencesHelper.getPassword().then((password) {
      if (password != null) {
        passwordController.text = password;
      }
    });
  }

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
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(15),
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
              Text("Selamat datang kembali!",
                  style: AppStyles.headingTextStyle),
              SizedBox(height: screenHeight * 0.0075),
              Text("Anda telah dirindukan, Kami senang bertemu Anda lagi!",
                  style: AppStyles.hintTextStyle),
              SizedBox(height: screenHeight * 0.05625),
              const LabelBuilder(text: "Alamat Email"),
              SizedBox(height: screenHeight * 0.015),
              FormBuilder(
                hintText: "hello@mangcoding.com",
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
                hintText: "Mangcoding123",
                formController: passwordController,
                validator: validatePassword,
                isPassword: true,
                isDescription: false,
                keyboardType: TextInputType.text,
              ),
              SizedBox(height: screenHeight * 0.015),
              forgotPass(text: 'Lupa Password', onTap: () {}),
              SizedBox(height: screenHeight * 0.03),
              ButtonBuilder(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      try {
                        LoginResponse login = await authApi.login(
                            emailController.text, passwordController.text);
                        if (login.email != "") {
                          SharedPreferencesHelper.saveId(login.id);
                          SharedPreferencesHelper.saveToken(login.token);
                          SharedPreferencesHelper.saveEmail(login.email);
                          SharedPreferencesHelper.savePassword(
                              passwordController.text);
                        }
                        if (login.profile.nama != "") {
                          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                        } else {
                          Navigator.pushNamedAndRemoveUntil(context, '/addProfile', (route) => false);
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
                  child: const Text("Masuk")),
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
              SizedBox(height: screenHeight * 0.025),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LogoBuilder(
                      onTap: () {
                        showFeatureNotWorking(context);
                      },
                      image: 'images/google-logo.png'),
                  const SizedBox(width: 10),
                  LogoBuilder(
                      onTap: () {
                        showFeatureNotWorking(context);
                      },
                      image: 'images/facebook-logo.png'),
                  const SizedBox(width: 10),
                  LogoBuilder(
                      onTap: () {
                        showFeatureNotWorking(context);
                      },
                      image: 'images/x-logo.png'),
                ],
              ),
              SizedBox(height: screenHeight * 0.05625),
              dontHaveAcc(context: context),
            ],
          ),
        ),
      ),
    ));
  }

  GestureDetector forgotPass(
      {required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: () => () {},
      child: Text("Lupa kata sandi anda?", style: AppStyles.heading3TextStyle),
    );
  }

  dontHaveAcc({required BuildContext context}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                  text: "Tidak punya akun? ", style: AppStyles.labelTextStyle),
              TextSpan(
                text: "Buat Akun",
                style: AppStyles.heading3PrimaryTextStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    Navigator.pushNamed(context, '/regist');
                  },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
