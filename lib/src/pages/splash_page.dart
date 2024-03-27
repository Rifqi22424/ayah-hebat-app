// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../models/login_response_model.dart';
import '../utils/shared_preferences.dart';
import '../widgets/image_cover_builder.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  AuthApi authApi = AuthApi();

  _getToken() async {
    final String? email = await SharedPreferencesHelper.getEmail();
    final String? pass = await SharedPreferencesHelper.getPassword();

    if (email != null && email != "" && pass != null && pass != "") {
      try {
        LoginResponse login = await authApi.login(email, pass);
        SharedPreferencesHelper.saveId(login.id);
        SharedPreferencesHelper.saveToken(login.token);
        if (login.profile.nama != "") {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          Navigator.pushReplacementNamed(context, '/addProfile');
        }
      } catch (e) {
        Navigator.pushReplacementNamed(context, "/login");
      }
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    _delayAndPush(context);

    return Scaffold(
      body: _splashImages(),
    );
  }

  void _delayAndPush(BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 1000), () {
      _getToken();
    });
  }

  Widget _splashImages() {
    return const ImageCoverBuilder(imagePath: 'images/splash-images.png');
  }
}
