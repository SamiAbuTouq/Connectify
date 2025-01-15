import 'package:flutter/material.dart';
import '/widgets/select_container_widget.dart';
import '../module/shared_data.dart';

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Connectify',
          style: TextStyle(
            fontFamily: "F1",
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 30,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                title1: 'Service Provider',
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
                backgroundColor: Colors.blue,
              ),
              onPressed: () {
                if (select1) {
                  sharedData['provider'] = 'true';

                  Navigator.pushNamed(context, "/experiance");
                } else if (select2) {
                  sharedData['provider'] = 'false';
                  storeUserInfo();

                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "/homePage",
                    (route) => false,
                  );
                } else {
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
