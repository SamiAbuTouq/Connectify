import 'package:flutter/material.dart';

class SplachScreenLoader extends StatelessWidget {
  const SplachScreenLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      backgroundColor: Color.fromARGB(255, 0, 195, 255),
      color: Color.fromARGB(255, 0, 0, 0),
    );
  }
}
