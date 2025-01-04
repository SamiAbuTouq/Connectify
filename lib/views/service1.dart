import 'package:flutter/material.dart';

class Service1 extends StatefulWidget {
  const Service1({super.key});
  @override
  State<StatefulWidget> createState() {
    return _Service1State();
  }
}

class _Service1State extends State<Service1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centered Text'),
      ),
      body: const Center(
        child: Text('Service 1'),
      ),
    );
  }
}
