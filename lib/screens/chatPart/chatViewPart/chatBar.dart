import 'package:flutter/material.dart';

class ChatBar extends StatefulWidget {
  final Widget recButton;
  final Widget expandedView;

  const ChatBar({
    Key? key,
    required this.recButton,
    required this.expandedView,
  }) : super(key: key);

  @override
  _ChatBarState createState() => _ChatBarState();
}
///===================================================================================
class _ChatBarState extends State<ChatBar> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: widget.expandedView),

            SizedBox(width: 5,),
            widget.recButton
          ],
        ),
      ),
    );
  }
}
