import 'package:flutter/material.dart ';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(255, 255, 254, 254),
            spreadRadius: 20,
            blurRadius: 300,
            offset: Offset(5, 5),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.fromLTRB(16, 0, 16, 15),
      child: Image.asset(
        'assets/images/logo/T-logo.png',
        colorBlendMode: BlendMode.darken,
      ),
    );
  }
}
