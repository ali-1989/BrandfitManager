import 'package:flutter/material.dart';

class BrokenImageView extends StatelessWidget {
  final Color? color;
  final double size;
  final bool center;

  BrokenImageView({
    this.size = 90.0,
    this.center = true,
    this.color,
    Key? key,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    if(center) {
      return Center(child: Icon(Icons.broken_image, size: size, color: color,));
    }

    return Icon(Icons.broken_image, size: size, color: color,);
  }
}