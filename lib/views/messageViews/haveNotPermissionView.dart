import 'package:flutter/material.dart';

import '/system/extensions.dart';
import '/tools/app/appThemes.dart';

class HaveNotPermissionView extends StatelessWidget {
  //final State state;
  //final TryAgain? tryAgain;
  final Color? iconColor;
  final double iconSize;
  final TextStyle? textStyle;

  HaveNotPermissionView(/*this.state, */{
    //this.tryAgain,
    this.iconColor,
    this.iconSize = 72,
    this.textStyle,
    Key? key,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color myColor = iconColor?? AppThemes.currentTheme.textColor;

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,

        children: <Widget>[
          Icon(Icons.pan_tool, size: iconSize, color: myColor,),
          const SizedBox(height: 12,),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(context.t('sorryYouDoNotHaveAccess')!,
              style: textStyle,
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,),
          ),
        ],
      ),
    );
  }
}
