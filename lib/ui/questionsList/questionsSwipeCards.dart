import 'package:flutter/material.dart';
import 'package:swipe_stack/swipe_stack.dart';

class QuestionsSwipeCards extends StatefulWidget {
  final List questionsListTest;
  final swipeKey;
  final int currentIndex;

  const QuestionsSwipeCards({
    Key key,
    @required this.questionsListTest,
    @required this.swipeKey,
    @required this.currentIndex,
  }) : super(key: key);

  @override
  _QuestionsSwipeCardsState createState() =>
      _QuestionsSwipeCardsState(currentIndex);
}

class _QuestionsSwipeCardsState extends State<QuestionsSwipeCards> {
  final int currentIndex;

  _QuestionsSwipeCardsState(this.currentIndex);
  changeIndex(index) {
    setState(() {
      index['id'] = currentIndex;
    });

    return index;
  }

  @override
  Widget build(BuildContext context) {
    return SwipeStack(
        key: widget.swipeKey,
        children: widget.questionsListTest.reversed.map((index) {
          return SwiperItem(
              builder: (SwiperPosition position, double progress) {
            return Material(
                elevation: 4,
                borderRadius: BorderRadius.all(Radius.circular(6)),
                child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(index['question_data'],
                            style:
                                TextStyle(color: Colors.black, fontSize: 20)),
                        Text("Progress $position",
                            style: TextStyle(color: Colors.blue, fontSize: 12)),
                      ],
                    )));
          });
        }).toList(),
        animationDuration: Duration(seconds: 2),
        historyCount: 1,
        visibleCount: 3,
        stackFrom: StackFrom.Top,
        translationInterval: 6,
        scaleInterval: 0.03,
        onSwipe: (int index, SwiperPosition position) => {
              SwiperPosition.None,
              if (SwiperPosition.Right != null)
                {print('right')}
              else if (SwiperPosition.Left != null)
                {print('left')}
            },
        onEnd: () => debugPrint("onEnd"),
        onRewind: (int index, SwiperPosition position) => SwiperPosition.None);
  }
}
