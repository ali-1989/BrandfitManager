import 'package:flutter/widgets.dart';

abstract class ViewController {
  void onInitState<E extends State>(covariant E state);

  void onBuild();

  void onDispose();
}