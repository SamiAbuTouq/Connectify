import 'package:animate_do/animate_do.dart';
import 'package:flutter_cloudinary_file_upload/views/service.dart';

// import 'package:day35/pages/cleaning.dart';
import 'package:flutter/material.dart';

class SelectService11 extends StatefulWidget {
  const SelectService11({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SelectServiceState();
  }
}

class _SelectServiceState extends State<SelectService11> {
  List<Service> services = [
    Service('Electrician', 'https://icons8.com/icon/PQn9wpEzc0Gj/electrician'),
    Service('Carpenter', 'https://icons8.com/icon/tNE4bATltVsL/saw'),
    Service('Painting', 'https://icons8.com/icon/9TqTwCc0UVkM/paint-roller'),
    Service('Plumber',
        'https://img.icons8.com/?size=100&id=xFN45rDF7HLr&format=png&color=000000'),
    Service('HVAC', 'https://icons8.com/icon/13151/cooling'),
    Service('Pest Control', 'https://icons8.com/icon/qkaeABjCUYMw/no-fly'),
    Service('Gardening', 'https://icons8.com/icon/htOOvGIOQJR2/garden'),
  ];

  int selectedService = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: selectedService >= 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, "/service${selectedService + 1}");
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
        setState(
          () {
            if (selectedService == index) {
              selectedService = -1;
            } else {
              selectedService = index;
            }
          },
        );
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
