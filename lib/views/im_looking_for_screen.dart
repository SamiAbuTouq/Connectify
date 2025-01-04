import '/widgets/logo.dart';
import 'package:flutter/material.dart';
import '/widgets/select_container_widget.dart';

class ImLookingForScreen extends StatefulWidget {
  const ImLookingForScreen({super.key});

  @override
  State<ImLookingForScreen> createState() => _ImLookingForState();
}

class _ImLookingForState extends State<ImLookingForScreen> {
  bool select1 = false;
  bool select2 = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Logo(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 36),
            const Text(
              "I am a...",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () {
                setState(() {
                  select1 = true;
                  select2 = false;
                });
              },
              child: SelectContainerWidget(
                title1: 'Service Providers',
                title2: "I offer professional services",
                img: select1
                    ? 'assets/images/others/check.png'
                    : 'assets/images/others/uncheck.png',
                select: select1,
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  select1 = false;
                  select2 = true;
                });
              },
              child: SelectContainerWidget(
                title1: "Looking For Service",
                title2: "I am looking for home services",
                img: select2
                    ? 'assets/images/others/check.png'
                    : 'assets/images/others/uncheck.png',
                select: select2,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward),
              iconAlignment: IconAlignment.end,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                iconColor: Colors.white,
                iconSize: 22,
                foregroundColor: Colors.white,
                backgroundColor: Colors.black,
                side: const BorderSide(
                    color: Color.fromARGB(255, 255, 255, 255), width: 2),
                elevation: 20,
                shadowColor:
                    const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 40),
              ),
              onPressed: () {
                if (select1) {
                  Navigator.pushNamed(context, "/selectService");
                } else if (select2) {
                  Navigator.pushNamed(context, "/mainPage");
                } else {
                  // Show an alert if no option is selected
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select an option first.'),
                    ),
                  );
                }
              },
              label: const Text(
                "Next",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
