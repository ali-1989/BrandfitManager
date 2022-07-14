import 'package:flutter/material.dart';

import '/system/extensions.dart';
import '/system/typedefs.dart';

// loginFn: AppNavigator.replaceCurrentRoute(state.context, LoginScreen(), name: LoginScreen.screenName);

class MustLoginView extends StatelessWidget {
  final State state;
  final TryLogin? loginFn;

  MustLoginView(this.state, {this.loginFn, Key? key}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${context.tC('mustLoginFirstByAccount')}', textAlign: TextAlign.center,)
                .subAlpha().fsR(2).boldFont(),
            const SizedBox(height: 16,),

            if(loginFn != null)
            TextButton(
              child: Text('${context.t('login')}').underLineClickable(),
              onPressed: (){
                loginFn?.call(state);
              },
            ),
          ],
        ),
      ),
    );
  }
}
