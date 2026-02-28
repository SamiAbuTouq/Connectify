import 'package:animate_do/animate_do.dart';
import 'package:connectify/views/service.dart';
import 'package:flutter/material.dart';
import 'package:connectify/module/shared_data.dart';

class SelectService17 extends StatefulWidget {
  const SelectService17({super.key});
  @override
  State<StatefulWidget> createState() {
    return _Service17State();
  }
}

class _Service17State extends State<SelectService17> {
  List<Service> services = [
    Service('General Cleaning',
        'https://img.icons8.com/3d-fluency/94/broom.png'),
    Service('Deep Cleaning',
        'https://img.icons8.com/3d-fluency/94/washing-machine.png'),
    Service('Kitchen Cleaning',
        'https://img.icons8.com/3d-fluency/94/cooker--v3.png'),
    Service('Bathroom Cleaning',
        'https://img.icons8.com/3d-fluency/94/shower.png'),
    Service('Window Cleaning',
        'https://img.icons8.com/3d-fluency/94/window.png'),
    Service('Carpet Cleaning',
        'https://img.icons8.com/3d-fluency/94/vacuum-cleaner.png'),
  ];

  Set<int> selectedServices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: selectedServices.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                sharedData['subServices'] = selectedServices
                    .map((index) => services[index].name)
                    .toList();

                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.blue,
                            size: 60,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Account Created",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Welcome aboard! Your service provider account is now live. Start connecting and creating remarkable experiences!",
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              storeUserInfo();
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                "/homePage",
                                (route) => false,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Text(
                              "Home",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
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
                  'Pick the services\n you can deliver',
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
                        delay: Duration(milliseconds: 350 * index),
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
        setState(
          () {
            if (selectedServices.contains(index)) {
              selectedServices.remove(index);
            } else {
              selectedServices.add(index);
            }
          },
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: selectedServices.contains(index)
              ? Colors.blue.shade50
              : Colors.grey.shade100,
          border: Border.all(
            color: selectedServices.contains(index)
                ? Colors.blue
                : const Color.fromARGB(0, 33, 149, 243),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network(image, height: 80),
            const SizedBox(
              height: 20,
            ),
            Text(
              name,
              textAlign: TextAlign.center,
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
