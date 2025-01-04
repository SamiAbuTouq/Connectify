import 'package:flutter/material.dart';

class Service2 extends StatefulWidget {
  const Service2({super.key});
  @override
  State<StatefulWidget> createState() {
    return _Service2State();
  }
}

class _Service2State extends State<Service2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centered Text'),
      ),
      body: const Center(
        child: Text('Service 2'),
      ),
    );
  }
}
