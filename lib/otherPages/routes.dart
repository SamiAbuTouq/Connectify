import 'splash.dart';
import 'main_page.dart';
import '/views/login.dart';
import '/views/start.dart';
import '/views/signup.dart';
import '../views/upload.dart';
import '/views/upload_area.dart';
import '/services/auth_service.dart';
import 'package:flutter/material.dart';
import '../views/select_service_1.dart';
// import '../views/select_service_2.dart';
import '../views/im_looking_for_screen.dart';
import '/onboarding/onboarding_screens.dart';
import '../views/select_service_1/select_service_1_1.dart';
import '../views/select_service_1/select_service_1_2.dart';
import '../views/select_service_1/select_service_1_3.dart';
import '../views/select_service_1/select_service_1_4.dart';
import '../views/select_service_1/select_service_1_5.dart';
import '../views/select_service_1/select_service_1_6.dart';
import '../views/select_service_1/cleaning.dart';
import '../views/experiance.dart';

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
  "/imLookingFor": (context) => const ImLookingForScreen(),
  "/selectService": (context) => const SelectService(),
  "/service1": (context) => const SelectService11(),
  "/service2": (context) => const SelectService12(),
  "/service3": (context) => const SelectService13(),
  "/service4": (context) => const SelectService14(),
  "/service5": (context) => const SelectService15(),
  "/service6": (context) => const SelectService16(),
  "/service7": (context) => const SelectService17(),
  "/experiance": (context) => const Experiance(),
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
