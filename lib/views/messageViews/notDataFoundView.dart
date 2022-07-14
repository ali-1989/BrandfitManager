import 'package:flutter/material.dart';

import '/system/extensions.dart';

class NotDataFoundView extends StatelessWidget {
  //final State state;
  //final TryAgain? tryAgain;
  final String? message;
  final TextStyle? textStyle;

  NotDataFoundView(/*this.state,*/ {
    this.message,
    this.textStyle,
    Key? key,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${message?? context.tC('thereAreNoResults')}',
              style: textStyle,
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,).subAlpha(),
          ],
        ),
      ),
    );
  }
}
