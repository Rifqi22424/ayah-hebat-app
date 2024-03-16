import 'package:ayahhebat/src/pages/change_password_page.dart';
import 'package:ayahhebat/src/pages/news_content_page.dart';
import 'package:ayahhebat/src/pages/profiles/edit_profile.dart';
import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/main_page.dart';
import '../pages/profiles/add_profile_page.dart';
import '../pages/regist_page.dart';
import '../pages/splash_page.dart';
import '../pages/verification_page.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return MaterialPageRoute(builder: (context) => const SplashPage());
      case "/login":
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case "/regist":
        return MaterialPageRoute(builder: (context) => const RegistPage());
      case "/verification":
        final args = settings.arguments as Map<String, dynamic>;
        final String email = args['email'];
        return MaterialPageRoute(
            builder: (context) => VerificationPage(
                  email: email,
                ));
      case "/profile":
        return MaterialPageRoute(
            builder: (context) => const MainPage(index: 2));
      case "/addProfile":
        return MaterialPageRoute(builder: (context) => const AddProfilePage());
      case "/editProfile":
        return MaterialPageRoute(builder: (context) => const EditProfilePage());
      case "/changePassword":
        return MaterialPageRoute(
            builder: (context) => const ChangePasswordPage());
      case "/home":
        return MaterialPageRoute(
            builder: (context) => const MainPage(
                  index: 0,
                ));
      case "/news":
        return MaterialPageRoute(
            builder: (context) => const MainPage(
                  index: 1,
                ));
      case "/newsContent":
        return MaterialPageRoute(builder: (context) => const NewsContentPage());
    }
    return _errorRoute();
  }
}

Route<dynamic> _errorRoute() {
  return MaterialPageRoute(
    builder: (context) {
      return const Scaffold(
        body: Center(
          child: Text('Error Route'),
        ),
      );
    },
  );
}
