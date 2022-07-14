import 'package:flutter/material.dart';

import 'package:iris_tools/api/helpers/animationHelper.dart';

import '/tools/app/appThemes.dart';
import '/tools/centers/localeCenter.dart';

//import 'package:loading_animations/loading_animations.dart';


class PreWidgets {
  PreWidgets._();

  static Widget notFound({double w = 110, double h = 110, double opacity = 0.4, Color? color}) {
    color = color?? AppThemes.currentTheme.textColor;

    return Opacity(
      opacity: opacity,
      child: Image.asset('assets/images/nf.png',
        color: color,
        width: w,
        height: h,
      ),
    );
  }

  static Widget flutterLoadingWidget({double w = 100, double h = 100, double strokeWidth = 2, Color? color}) {
    color = color?? AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor);

    return ConstrainedBox(
        constraints: BoxConstraints(minWidth:5, maxWidth: w, minHeight: 5, maxHeight: h),
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          valueColor: AnimationHelper.getValueColor(color),
        )
    );
  }

  static Widget flutterLoadingWidget$Center({double w = 100, double h = 100, double strokeWidth = 2, Color? color}) {
    return Center(
        child: flutterLoadingWidget(
          color: color,
          h: h,
          w: w,
          strokeWidth: strokeWidth,
        )
    );
  }

  static Widget flutterProgressView({double size = 42, double? value, double strokeWidth = 2, Color? color}) {
    //color = color?? AppThemes.currentTheme.primaryColor;

    return SizedBox(
      width: size,
      height: size,
      child: value != null ? CircularProgressIndicator(value: value,) : const CircularProgressIndicator(),
    );
  }

  /*static Widget bouncingGridLoadingView({Color? color, Color? borderColor, double? size, double borderSize = 0.0}) {
    size ??= AppSizes.imageMultiplier * 13;

    final animColor = AppThemes.currentTheme.activeItemColor;

    return LoadingBouncingGrid.circle(
      key: ValueKey(Generator.generateKey(5)),//use key for change color on changed theme
      borderSize: borderSize,
      size: size,
      borderColor: borderColor?? ColorHelper.changeLight(animColor),
      backgroundColor: color?? animColor,
    );
  }*/

  static Widget prepareLoadWidget({double w = 100, double h = 100, double strokeWidth = 4, Color? color}) {
    color = color?? AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor);

    return ConstrainedBox(
        constraints: BoxConstraints(minWidth:5, maxWidth: w, minHeight: 5, maxHeight: h),
        child: Stack(
          children: [
            CircularProgressIndicator(
              strokeWidth: strokeWidth,
              valueColor: AnimationHelper.getValueColor(color),
            ),

            Positioned.fill(
                child: Icon(Icons.close, color: color,)
            ),
          ],
        )
    );
  }

  // value 0.0 - 1.0
  static Widget progressLoadView(double value, {
    double w = 100,
    double h = 100,
    double strokeWidth = 4,
    Color? color,
    Color? backColor,
    }) {
    if(value > 1.0){
      throw Exception('value must b/w 0 -1'); //MathHelper.percentTop1(69)
    }

    color = color?? AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor);

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth:5, maxWidth: w, minHeight: 5, maxHeight: h),
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth,
            backgroundColor: backColor,
            valueColor: AnimationHelper.getValueColor(color),
          ),

          Positioned.fill(
              child: Icon(Icons.close, color: color,)
          ),
        ],
      ),
    );
  }

  static Widget playCircleIcon({double size = 40.0, Color? color, Color? aroundColor}) {
    aroundColor ??= Colors.black.withAlpha(70);
    color ??= Colors.white;

    return DecoratedBox(
        decoration: ShapeDecoration(
            color: aroundColor,
            shape: CircleBorder()
        ),
        child: Padding(
          padding: EdgeInsets.all(2.0),
          child: Icon(Icons.play_circle_fill_rounded, size: size, color: color,),
        )
    );
  }

  static Widget updating({
    String? text,
    TextDirection? dir,
    Color? color,
    double iconSize = 21,
    TextStyle? textStyle,
    double space = 3.0,
  }) {

    text ??= LocaleCenter.appLocalize.translateCapitalize('dataUpdating');

    dir ??= AppThemes.textDirection;

    color ??= AppThemes.checkPrimaryByWB(AppThemes.currentTheme.primaryColor, AppThemes.currentTheme.differentColor);

    return Builder(
      builder:(ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if(text != null)
                Text(text, style: textStyle,),

              SizedBox(width: space,),

              /*bouncingGridLoadingView(
                borderSize: 0.0,
                color: color,
                borderColor: Colors.transparent,
                size: iconSize,
              ),*/
            ],

          ),
        );
      },
    );
  }


}
