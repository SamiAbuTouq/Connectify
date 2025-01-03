import 'main_Page.dart';
import 'splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cloudinary_file_upload/views/home.dart';
import 'package:flutter_cloudinary_file_upload/views/login.dart';
import 'package:flutter_cloudinary_file_upload/views/signup.dart';
import 'package:flutter_cloudinary_file_upload/views/upload_area.dart';
import 'package:flutter_cloudinary_file_upload/services/auth_service.dart';
import 'package:flutter_cloudinary_file_upload/onboarding/onboarding_screens.dart';

final Map<String, WidgetBuilder> appRoutes = {
  "/": (context) => const CheckUser(),
  "/home": (context) => const HomePage(),
  "/login": (context) => const LoginPage(),
  "/signup": (context) => const SignupPage(),
  "/upload": (context) => const UploadArea(),
  "/splashScreen": (context) => const SplashScreen(),
  "/mainPage": (context) => const MainPage(),
  "/onboardingScreens": (context) => const OnboardingScreens(),
};

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    AuthService().isLoggedIn().then((value) {
      if (value) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        Navigator.pushReplacementNamed(context, "/splashScreen");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
