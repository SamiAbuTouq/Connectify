import 'package:flutter/material.dart';

class SelectContainerWidget extends StatelessWidget {
  final String title1;
  final String title2;
  final String img;
  final bool select;
  const SelectContainerWidget({
    super.key,
    required this.title1,
    required this.title2,
    required this.img,
    required this.select,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 327,
      height: 152,
      decoration: BoxDecoration(
        color: (!select) ? Colors.transparent : const Color(0xFFE7F1FC),
        borderRadius: BorderRadius.circular(6),
        border: (select)
            ? Border.all(color: const Color(0xFF0773DA))
            : Border.all(color: const Color.fromARGB(255, 0, 0, 0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title1,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'F2',
                ),
              ),
              Text(
                title2,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
          Image.asset(
            img,
            width: 17,
          ),
        ],
      ),
    );
  }
}
