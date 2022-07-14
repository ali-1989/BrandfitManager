import 'package:flutter/material.dart';

import '/system/extensions.dart';
import '/system/typedefs.dart';
import '/tools/app/appThemes.dart';

class NetIsDisconnectView extends StatelessWidget {
  final State state;
  final TryAgain? tryAgain;
  final Color? iconColor;
  final double iconSize;
  final TextStyle? textStyle;
  final TextStyle? tryAgainTextStyle;

  NetIsDisconnectView(this.state, {
    this.tryAgain,
    this.iconColor,
    this.iconSize = 72,
    this.textStyle,
    this.tryAgainTextStyle,
    Key? key,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    var myColor = iconColor?? AppThemes.currentTheme.textColor;
    var myStyle = tryAgainTextStyle?? AppThemes.currentTheme.textUnderlineStyle;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Stack(
              children: <Widget>[
                /*Icon(Icons.wifi, size: iconSize, color: myColor,),
                Icon(Icons.not_interested, size: iconSize, color: myColor,),*/
                Icon(Icons.signal_wifi_off, size: iconSize, color: myColor,),
              ],
            ),

            const SizedBox(height: 10,),
            Text(context.tC('netConnectionIsDisconnect')!,
              style: textStyle,
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,),

            const SizedBox(height: 10,),
            TextButton(
              child: Text('${context.t('tryAgain')}', style: myStyle).underLineClickable(),
              onPressed: (){
                tryAgain?.call(state);
              },
            ),
          ],
        ),
      ),
    );
  }
}
