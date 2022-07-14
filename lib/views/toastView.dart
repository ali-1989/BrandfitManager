import 'package:flutter/material.dart';

import 'package:animate_do/animate_do.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';

import '/tools/app/appThemes.dart';

class ToastView extends StatelessWidget {
  final Widget child;
  final Color? backColor;
  final double bottomOffset;

  ToastView(this.child, {this.backColor, this.bottomOffset = 40, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    final myBackColor = backColor??
        (ColorHelper.isNearColor(Colors.black, AppThemes.currentTheme.primaryColor)?
      Colors.grey.withAlpha(150) : Colors.black.withAlpha(200));

    return FadeIn(
      duration: const Duration(milliseconds: 600),
      child: FadeOut(
        delay: const Duration(milliseconds: 3000),
        duration: const Duration(milliseconds: 500),
        animate: true,
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 0, 10, bottomOffset),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                  color: myBackColor),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
