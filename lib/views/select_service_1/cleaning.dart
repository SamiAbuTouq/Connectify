import 'package:flutter/material.dart';

class SelectService17 extends StatefulWidget {
  const SelectService17({super.key});
  @override
  State<StatefulWidget> createState() {
    return _Service17State();
  }
}

class _Service17State extends State<SelectService17> {
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
