import 'package:flutter/material.dart';

import '/system/extensions.dart';
import '/system/typedefs.dart';

class CommunicationErrorView extends StatelessWidget {
  final State state;
  final TryAgain? tryAgain;
  final TextStyle? textStyle;
  final TextStyle? tryAgainTextStyle;

  CommunicationErrorView(this.state, {
    this.tryAgain,
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
          children: [
            Text('${context.tC('errorCommunicatingServer')}',
              style: textStyle,
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,).subAlpha(),

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
