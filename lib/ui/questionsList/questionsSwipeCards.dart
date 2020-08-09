import 'package:flutter/material.dart';
import 'package:swipe_stack/swipe_stack.dart';

class QuestionsSwipeCards extends StatefulWidget {
  final List questionsListTest;
  final swipeKey;
  final int currentIndex;
  final Function answersCallBack;

  const QuestionsSwipeCards({
    Key key,
    @required this.questionsListTest,
    @required this.swipeKey,
    @required this.currentIndex,
    @required this.answersCallBack,
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
    return Center(
      child: SwipeStack(
          key: widget.swipeKey,
          children: widget.questionsListTest.map((index) {
            // add function for chnage index depends on the data in the local storage
            return SwiperItem(
                builder: (SwiperPosition position, double progress) {
              return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(30)),
                  ),
                  child: Center(
                    child: Text(index['question_data'],
                        style: TextStyle(color: Colors.black, fontSize: 20)),
                  ));
            });
          }).toList(),
          animationDuration: Duration(seconds: 2),
          threshold: 2,
          historyCount: 1,
          visibleCount: 3,
          stackFrom: StackFrom.Top,
          translationInterval: 6,
          scaleInterval: 0.03,
          onSwipe: (int index, SwiperPosition position) => {
                // if (SwiperPosition.Right != null)
                //   {print('right')}
                // else if (SwiperPosition.Left != null)
                //   {print('left')}
              },
          onEnd: () => debugPrint("onEnd"),
          onRewind: (int index, SwiperPosition position) =>
              SwiperPosition.None),
    );
  }
}
