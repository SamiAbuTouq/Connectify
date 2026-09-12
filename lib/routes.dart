import 'onboarding/splash.dart';
import '/views/login.dart';
import '/views/signup.dart';
import 'views/upload_img.dart';
import 'views/experience.dart';
import 'package:connectify/widgets/circular_progress_indicator.dart';
import '/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'views/select_service_page.dart';
import 'homepage/pages/home_page.dart';
import 'homepage/pages/provider_dashboard_page.dart';
import 'views/im_looking_for_screen.dart';
import '/onboarding/onboarding_screens.dart';
import 'views/select_service_1/cleaning.dart';
import 'homepage/pages/help_support_page.dart';
import 'package:connectify/homepage/pages/chatbot.dart';
import 'views/select_service_1/select_service_1_1.dart';
import 'views/select_service_1/select_service_1_2.dart';
import 'views/select_service_1/select_service_1_3.dart';
import 'views/select_service_1/select_service_1_4.dart';
import 'views/select_service_1/select_service_1_5.dart';
import 'views/select_service_1/select_service_1_6.dart';
import 'package:connectify/homepage/pages/send_email_page.dart';
import 'package:connectify/homepage/pages/profile_page.dart';
import 'package:connectify/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final Map<String, WidgetBuilder> appRoutes = {
  "/": (context) => const CheckUser(),
  "/uploadPhoto": (context) => const UploadPhoto(),
  "/login": (context) => const LoginPage(),
  "/signup": (context) => const SignupPage(),
  "/splashScreen": (context) => const SplashScreen(),
  "/homePage": (context) => const HomePage(),
  "/onboardingScreens": (context) => const OnboardingScreens(),
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
  "/helpSupportPage": (context) => const HelpSupportPage(),
  "/chatbot": (context) => const ChatbotPage(),
  "/sendEmail": (context) => const SendEmailPage(),
  "/profilePage": (context) => const ProfilePage(),
  "/providerDashboard": (context) => const ProviderDashboardPage(),
};

class CheckUser extends StatefulWidget {
  const CheckUser({super.key});

  @override
  State<CheckUser> createState() => _CheckUserState();
}

class _CheckUserState extends State<CheckUser> {
  @override
  void initState() {
    super.initState();
    _resolveRoute();
  }

  Future<void> _resolveRoute() async {
    final loggedIn = await AuthService().isLoggedIn();
    if (!loggedIn) {
      if (mounted) Navigator.pushReplacementNamed(context, '/splashScreen');
      return;
    }

    // Fetch the user's role from Firestore
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      // Sync FCM device token
      NotificationService.instance.saveUserToken(uid);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      final role = (doc.data()?['role'] as String?) ?? 'seeker';
      if (!mounted) return;
      if (role == 'provider') {
        Navigator.pushReplacementNamed(context, '/providerDashboard');
      } else {
        Navigator.pushReplacementNamed(context, '/homePage');
      }
    } catch (_) {
      // On any Firestore error fall back to seeker home
      if (mounted) Navigator.pushReplacementNamed(context, '/homePage');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SplachScreenLoader(message: 'Loading Connectify...'),
    );
  }
}
