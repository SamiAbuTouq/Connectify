import 'splash.dart';
import 'main_Page.dart';
import '/views/home.dart';
import '/views/login.dart';
import '/views/start.dart';
import '/views/signup.dart';
import '../views/service1.dart';
import '../views/service2.dart';
import '/views/upload_area.dart';
import '/services/auth_service.dart';
import '../views/select_service_1.dart';
import 'package:flutter/material.dart';
import '../views/im_looking_for_screen.dart';
import '/onboarding/onboarding_screens.dart';

final Map<String, WidgetBuilder> appRoutes = {
  "/": (context) => const CheckUser(),
  "/home": (context) => const HomePage(),
  "/login": (context) => const LoginPage(),
  "/signup": (context) => const SignupPage(),
  "/upload": (context) => const UploadArea(),
  "/splashScreen": (context) => const SplashScreen(),
  "/mainPage": (context) => const MainPage(),
  "/onboardingScreens": (context) => const OnboardingScreens(),
  "/startPage": (context) => const StartPage(),
  "/selectService": (context) => const SelectService(),
  "/imLookingFor": (context) => const ImLookingForScreen(),
  "/service1": (context) => const Service1(),
  "/service2": (context) => const Service2(),
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
