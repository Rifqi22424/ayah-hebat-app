// ignore_for_file: use_build_context_synchronously

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../consts/app_colors.dart';
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
        print("login.token ${login.token}");
        SharedPreferencesHelper.saveToken(login.token);
        if (login.profile.nama != "") {
          Navigator.pushReplacementNamed(context, '/home');
          // RemoteMessage remoteMessage = RemoteMessage(
          //   notification: RemoteNotification(
          //     title: "Infaq Berhasil",
          //     body: "Infaq anda berhasil dikirimkan",
          //   ),
          //   data: {
          //     "id": "28aabdd0-e825-4cbd-a8c4-59e765fea78a",
          //     "userId": "5",
          //     "amount": "12000",
          //     "status": "pending",
          //     "orderId": "JTYH-1739431473195",
          //     "redirectUrl":
          //         "https://app.sandbox.midtrans.com/snap/v4/redirection/69fc04b1-43f0-4473-91f6-652de7bd10a1",
          //     "allocationTypeCode": "JTYH",
          //     "paymentType": "cstore",
          //     "createdAt":
          //         "Thu Feb 13 2025 14:24:34 GMT+0700 (Western Indonesia Time)",
          //     "updatedAt":
          //         "Thu Feb 13 2025 14:34:52 GMT+0700 (Western Indonesia Time)",
          //     "notificationType": "infaqNotification",
          //     "allocationType": "mubarahah"
          //   },
          // );
          // Navigator.pushNamed(context, '/resultInfaq',
          //     arguments: remoteMessage);
        } else {
          Navigator.pushReplacementNamed(context, '/addProfile');
        }
      } catch (e) {
        print(e.toString());
        Navigator.pushReplacementNamed(context, "/login");
      }
    } else {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        _getToken();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // _delayAndPush(context);

    return Scaffold(
      body: Expanded(
          child: Container(
        color: AppColors.primaryColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("images/splash_logo_aspect.png", width: 225),
              CircularProgressIndicator(
                color: AppColors.whiteColor,
              ),
            ],
          ),
        ),
      )),
    );
  }

  // Widget _splashImages() {
  // return const ImageCoverBuilder(imagePath: 'images/splash-images.png');
  // return const Text("Splash Screen");
  // }
}
