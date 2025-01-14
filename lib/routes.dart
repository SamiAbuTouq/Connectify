import 'otherPages/splash.dart';
import '/views/login.dart';
import '/views/start.dart';
import '/views/signup.dart';
import 'views/upload_img.dart';
import 'views/experiance.dart';
import '/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'views/select_service_1.dart';
import 'homepage/pages/home_page.dart';
import 'views/im_looking_for_screen.dart';
import '/onboarding/onboarding_screens.dart';
import 'views/select_service_1/cleaning.dart';
import 'views/select_service_1/select_service_1_1.dart';
import 'views/select_service_1/select_service_1_2.dart';
import 'views/select_service_1/select_service_1_3.dart';
import 'views/select_service_1/select_service_1_4.dart';
import 'views/select_service_1/select_service_1_5.dart';
import 'views/select_service_1/select_service_1_6.dart';
import '/otherPages/send_message.dart';
import 'homepage/pages/help_support_page.dart';
import 'package:connectify/homepage/pages/send_email_page.dart';
import 'package:connectify/homepage/pages/chatbot.dart';

final Map<String, WidgetBuilder> appRoutes = {
  "/": (context) => const CheckUser(),
  "/uploadPhoto": (context) => const UploadPhoto(),
  "/login": (context) => const LoginPage(),
  "/signup": (context) => const SignupPage(),
  "/splashScreen": (context) => const SplashScreen(),
  "/homePage": (context) => const HomePage(),
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
  "/sendMessagePage": (context) => const SendMessagePage(),
  "/helpSupportPage": (context) => const HelpSupportPage(),
  "/chatbot": (context) => const ChatbotPage(),
  "/sendEmail": (context) => const SendEmailPage(),
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
        Navigator.pushReplacementNamed(context, "/homePage");
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
