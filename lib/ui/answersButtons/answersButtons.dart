import 'package:flutter/material.dart';

class AnswersButtons extends StatelessWidget {
  final swipeKey;
  final List answersList;
  final Function answersCallBack;
  final item;

  const AnswersButtons(
      {Key key,
      @required this.swipeKey,
      @required this.answersList,
      @required this.answersCallBack,
      @required this.item})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: answersList.length,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        itemBuilder: (context, index) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                RaisedButton(
                  onPressed: () async {
                    await swipeKey.currentState.swipeRight();
                    answersCallBack(item);
                  },
                  child: Text(answersList[index]['answers_text']),
                )
              ],
            ));
  }
}
