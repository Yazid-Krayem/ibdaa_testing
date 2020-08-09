import 'package:flutter/material.dart';

class AnswersButtons extends StatelessWidget {
  final swipeKey;
  final List answersList;
  final Function answersCallBack;
  final item;
  final int currentIndex;

  const AnswersButtons(
      {Key key,
      @required this.swipeKey,
      @required this.answersList,
      @required this.answersCallBack,
      @required this.item,
      @required this.currentIndex})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: RaisedButton(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0),
          ),
          textColor: Colors.black,
          color: Colors.blue,
          onPressed: () async {
            // if (item.answerValue <= 0.33) {
            //   await swipeKey.currentState.swipeLeft();
            // } else {
            //   await swipeKey.currentState.swipeLeft();
            // }
            answersCallBack(item);
          },
          child: Text("${item.answersText}")),
    );
  }
}
