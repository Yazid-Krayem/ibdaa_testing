// import 'package:flutter/material.dart';
// import 'package:ibdaa_testing/ui/questionsList/questionsList.dart';

// class QuestionListAnimate extends AnimatedWidget {
//   final progress;
//   final currentIndex;
//   final listQuestions;
//   QuestionListAnimate({
//     Key key,
//     Animation<double> animation,
//     this.progress,
//     this.currentIndex,
//     this.listQuestions,
//   }) : super(key: key, listenable: animation);
//   @override
//   Widget build(BuildContext context) {
//     final Animation<double> animation = listenable;

//     return new AnimatedSwitcher(
//       duration: const Duration(seconds: 2),
//       child: IndexedStack(
//         key: ValueKey<int>(currentIndex),
//         index: currentIndex,
//         children: <Widget>[
//           for (var item in listQuestions)
//             QuestionsList(
//              fetchUsers: fe,
//             )
//         ],
//       ),
//     );
//   }
// }
