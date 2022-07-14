import 'package:flutter/material.dart';

class TopErrorView extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;

  TopErrorView(this.child, {this.gradient, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final myGradient = gradient?? const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFF63B04),
          Color(0xFFF03000),
          Color(0xFFF50B04),
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