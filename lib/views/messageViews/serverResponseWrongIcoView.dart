import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/system/extensions.dart';
import '/system/typedefs.dart';

class ServerResponseWrongIcoView extends StatelessWidget {
  final State state;
  final TryAgain? tryAgain;
  final Color? iconColor;
  final double iconSize;
  final TextStyle? textStyle;
  final TextStyle? tryAgainTextStyle;

  ServerResponseWrongIcoView(this.state, {
    this.tryAgain,
    this.iconColor,
    this.iconSize = 72,
    this.textStyle,
    this.tryAgainTextStyle,
    Key? key,
    }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(CupertinoIcons.minus_circled, size: iconSize, color: iconColor,),

            const SizedBox(height: 10,),
            Text(context.tC('serverNotRespondProperly')!,
              style: textStyle,
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,),

            const SizedBox(height: 16,),
            TextButton(
              child: Text('${context.t('tryAgain')}', style: tryAgainTextStyle).underLineClickable(),
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
