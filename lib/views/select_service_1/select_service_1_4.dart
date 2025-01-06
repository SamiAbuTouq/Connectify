import 'package:animate_do/animate_do.dart';
import 'package:flutter_cloudinary_file_upload/views/service.dart';
// import 'package:day35/pages/cleaning.dart';
import 'package:flutter/material.dart';

class SelectService14 extends StatefulWidget {
  const SelectService14({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SelectServiceState();
  }
}

class _SelectServiceState extends State<SelectService14> {
  List<Service> services = [
    Service('Salon at Home', 'https://icons8.com/icon/62eMNWPxv83B/barbershop'),
    Service('Massage at Home',
        'https://icons8.com/icon/KFzu6vahEoHL/infant-massage'),
    Service('Pet Care', 'https://icons8.com/icon/SDOwtRV0aMrE/cat-caregivers'),
    Service('Tailoring & Alterations',
        'https://icons8.com/icon/TkCArNjuDHlu/sewing-machine'),
  ];

  Set<int> selectedServices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: selectedServices.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                // Handle navigation for multiple services
                print("Selected services: $selectedServices");
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

  Widget serviceContainer(String image, String name, int index) {
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
