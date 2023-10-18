import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({super.key, 
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16.0,
    this.textColor = const Color(0xff505050),
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        )
      ],
    );
  }
}
