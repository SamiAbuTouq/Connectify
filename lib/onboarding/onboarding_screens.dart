import 'package:flutter/material.dart';
import 'onboarding_page.dart';
import 'transitions.dart';
import 'package:flutter_cloudinary_file_upload/views/login.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({Key? key}) : super(key: key);

  @override
  State<OnboardingScreens> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreens>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _animationController;
  int _currentPage = 0;
  final int _numPages = 4;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to Connectify!',
      'description':
          "Welcome to Connectify, where convenience meets excellence! Whether you're looking to get something fixed or you're the one making things happen, we're here to connect you to the right people. Let's make life easier, together!",
      'image': 'assets/images/onboarding/1.jpg'
    },
    {
      'title': "Need Help? We've Got You!",
      'description':
          "Dreaming of that perfect door installation or a glowing new light setup? It's just a tap away! Sign up as a service requester and find top-notch professionals ready to turn your home into the place you' ve always wanted",
      'image': 'assets/images/onboarding/2.jpg'
    },
    {
      'title': 'Your Skills, Your Service!',
      'description':
          "Are you a pro who loves solving problems? With Connectify, you can offer your expertise, grow your business, and connect with people who need your skills. The world's waiting for your magic!",
      'image': 'assets/images/onboarding/3.jpg'
    },
    {
      'title': 'Get Things Done with a Smile!',
      'description':
          "No more hassle! With Connectify, booking services and getting things done is smoother than ever. From booking to service completion, it's fast, fun, and stress-free just the way it should be!",
      'image': 'assets/images/onboarding/4.jpg'
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _numPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _numPages,
            itemBuilder: (context, index) {
              return OnboardingPage(
                title: _pages[index]['title']!,
                description: _pages[index]['description']!,
                imagePath: _pages[index]['image']!,
                isActive: index == _currentPage,
              );
            },
          ),
          Positioned(
            bottom: 48.0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _numPages,
                      (index) => TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 300),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: const Color.fromARGB(255, 0, 0, 0)),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        AnimatedSlideFade(
                          duration: const Duration(milliseconds: 400),
                          offset: const Offset(-20, 0),
                          child: TextButton(
                            onPressed: _previousPage,
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).primaryColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                            ),
                            child: const Text(
                              'Back',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                      AnimatedSlideFade(
                        duration: const Duration(milliseconds: 400),
                        offset: const Offset(20, 0),
                        child: ElevatedButton(
                          onPressed: _currentPage == _numPages - 1
                              ? () {
                                  Navigator.of(context).pushReplacement(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: const LoginPage(),
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 800),
                                    ),
                                  );
                                }
                              : _nextPage,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            _currentPage == _numPages - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
