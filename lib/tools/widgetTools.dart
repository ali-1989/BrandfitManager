import 'package:flutter/material.dart';

import '/tools/app/appThemes.dart';

class WidgetTools {
  WidgetTools._();

  static RoundedRectangleBorder getBorder({
    double radius = 10,
    double width = 0.8,
    Color? color,
    }) {
    color ??= AppThemes.currentTheme.fabBackColor.withAlpha(150);

    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: BorderSide(
        color: color,
        width: width,
      ),
    );
  }
}
///=======================================================================================
class ShapeList {
  ShapeList._();

  static ShapeBorder roundedRect$ShapeBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(
        Radius.circular(10),
      )
  );
  static ShapeBorder stadiumBorder$ShapeBorder = StadiumBorder();

  // OutlinedBorder
  static OutlinedBorder stadiumBorder$Outlined = StadiumBorder();
  static OutlinedBorder circleBorder$Outlined = CircleBorder();
  static OutlinedBorder continuousRectangle$Outlined = ContinuousRectangleBorder();
  static OutlinedBorder beveledRectangle$Outlined = BeveledRectangleBorder();
  static OutlinedBorder roundedRectangle$Outlined = RoundedRectangleBorder();

  // InputBorder
  static InputBorder outline$InputBorder = OutlineInputBorder();
  static InputBorder underline$InputBorder = UnderlineInputBorder();

  // BoxBorder
  static BoxBorder border$BoxBorder = Border();
  static BoxBorder borderDirectional$BoxBorder = BorderDirectional();
  static BoxBorder noneBorder$BoxBorder = Border.all(style: BorderStyle.none, width: 0);

  static BoxShape circle$BoxShape = BoxShape.circle;
  static BoxShape rectangle$BoxShape = BoxShape.rectangle;
}
