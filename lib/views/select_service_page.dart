import 'package:animate_do/animate_do.dart';
import 'service.dart';
import 'package:flutter/material.dart';
import '../module/shared_data.dart';

class SelectService extends StatefulWidget {
  const SelectService({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SelectServiceState();
  }
}

class _SelectServiceState extends State<SelectService> {
  List<Service> services = [
    Service('Home Maintenance',
        'https://img.icons8.com/3d-fluency/94/home-automation.png'),
    Service('Appliance Repair',
        'https://img.icons8.com/3d-fluency/94/maintenance.png'),
    Service('Technology & IT ',
        'https://img.icons8.com/3d-fluency/94/workstation.png'),
    Service('Personal & Lifestyle ',
        'https://img.icons8.com/3d-fluency/94/welfare.png'),
    Service('Educational & Tutoring',
        'https://img.icons8.com/3d-fluency/94/reading.png'),
    Service(
        'Event Support', 'https://img.icons8.com/3d-fluency/94/confetti.png'),
    Service('Cleaning',
        'https://img.icons8.com/external-vitaliy-gorbachev-flat-vitaly-gorbachev/2x/external-cleaning-labour-day-vitaliy-gorbachev-flat-vitaly-gorbachev.png'),
  ];

  int selectedService = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: selectedService >= 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, "/service${selectedService + 1}");
              },
              backgroundColor: Colors.blue,
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 20,
              ),
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverToBoxAdapter(
                child: FadeInUp(
              child: Padding(
                padding:
                    const EdgeInsets.only(top: 120.0, right: 20.0, left: 20.0),
                child: Text(
                  'what type of service \do you want to offer?',
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.grey.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ))
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 20.0,
                    mainAxisSpacing: 20.0,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (BuildContext context, int index) {
                    return FadeInUp(
                        delay: Duration(milliseconds: 500 * index),
                        child: serviceContainer(services[index].imageURL,
                            services[index].name, index));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  serviceContainer(String image, String name, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (selectedService == index) {
            selectedService = -1;
            sharedData.remove('mainService');
          } else {
            selectedService = index;
            sharedData['mainService'] = name;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: selectedService == index
              ? Colors.blue.shade50
              : Colors.grey.shade100,
          border: Border.all(
            color: selectedService == index
                ? Colors.blue
                : const Color.fromARGB(0, 33, 149, 243),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(image, height: 70),
            const SizedBox(
              height: 20,
            ),
            Text(
              name,
              style: const TextStyle(
                fontSize: 18,
              ),
            )
          ],
        ),
      ),
    );
  }
}
