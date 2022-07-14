import 'package:flutter/material.dart';

class TopInfoView extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  TopInfoView(this.child, {this.gradient, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final myGradient = gradient?? const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFCC0F),
          Color(0xFFF6C304),
          Color(0xFFE0C000),
        ]
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: DecoratedBox(
          decoration: BoxDecoration(
              gradient: myGradient),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 18),
            child: child,
          ),
        ),
      ),
    );
  }
}