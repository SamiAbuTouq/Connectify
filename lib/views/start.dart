import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'service.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  const StartPage({Key? key}) : super(key: key);

  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List<Service> services = [
    Service('Cleaning',
        'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'),
    Service('Plumber',
        'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-plumber-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'),
    Service('Electrician',
        'https://img.icons8.com/external-wanicon-flat-wanicon/2x/external-multimeter-car-service-wanicon-flat-wanicon.png'),
    Service('Painter',
        'https://img.icons8.com/external-itim2101-flat-itim2101/2x/external-painter-male-occupation-avatar-itim2101-flat-itim2101.png'),
    Service('Carpentfdsfer', 'https://img.icons8.com/fluency/2x/drill.png'),
    Service('Gardener',
        'https://img.icons8.com/external-itim2101-flat-itim2101/2x/external-gardener-male-occupation-avatar-itim2101-flat-itim2101.png'),
    Service('Tailor', 'https://img.icons8.com/fluency/2x/sewing-machine.png'),
    Service('Maid', 'https://img.icons8.com/color/2x/housekeeper-female.png'),
    Service('Driver',
        'https://img.icons8.com/external-sbts2018-lineal-color-sbts2018/2x/external-driver-women-profession-sbts2018-lineal-color-sbts2018.png'),
  ];

  int selectedService = 4;

  @override
  void initState() {
    print("StartPage ");
    // Randomly select from service list every 2 seconds
    Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        selectedService = Random().nextInt(services.length);
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              height: MediaQuery.of(context).size.height * 0.45,
              width: MediaQuery.of(context).size.width,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: services.length,
                itemBuilder: (BuildContext context, int index) {
                  return FadeInUp(
                    delay: Duration(milliseconds: index * 100),
                    child: serviceContainer(
                      services[index].imageURL,
                      services[index].name,
                      index,
                    ),
                  );
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(80),
                  topRight: Radius.circular(80),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 40,
                  ),
                  FadeInUp(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Center(
                        child: Text(
                          'Easy, reliable way to take \ncare of your home',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FadeInUp(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 60),
                      child: Center(
                        child: Text(
                          'We provide you with the best people to help take care of your home',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeInUp(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(50, 50, 50, 1),
                      child: MaterialButton(
                        elevation: 0,
                        color: Colors.black,
                        onPressed: () {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => SelectService(),
                          //   ),
                          // );
                        },
                        height: 55,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Get Started',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  serviceContainer(String image, String name, int index) {
    return GestureDetector(
      onTap: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedService == index ? Colors.white : Colors.grey.shade100,
          border: Border.all(
            color: selectedService == index
                ? Colors.blue.shade100
                : const Color.fromARGB(0, 158, 158, 158),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(image, height: 30),
            const SizedBox(
              height: 10,
            ),
            Text(
              name,
              style: const TextStyle(fontSize: 14),
            )
          ],
        ),
      ),
    );
  }
}
