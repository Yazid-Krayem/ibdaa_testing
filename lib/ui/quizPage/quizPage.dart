import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:ibdaa_testing/models/answersList.dart';
import 'package:ibdaa_testing/models/api.dart';
import 'package:ibdaa_testing/models/getAnswers.dart';
import 'package:ibdaa_testing/models/getQuestions.dart';
import 'package:http/http.dart' as http;
import 'package:ibdaa_testing/ui/answersButtons/answersButtons.dart';
import 'package:ibdaa_testing/ui/questionsList/questionsSwipeCards.dart';
import 'package:ibdaa_testing/ui/submitPage/submitPage.dart';
import 'package:js_shims/js_shims.dart';
import 'package:localstorage/localstorage.dart';
import 'package:swipe_stack/swipe_stack.dart';

class QuizPage extends StatefulWidget {
  final deviceId;
  final cookieName;
  final List oldData;

  QuizPage(this.deviceId, this.cookieName, this.oldData) : super();
  @override
  _QuizPageState createState() => _QuizPageState(deviceId, cookieName, oldData);

  static of(BuildContext context) {}
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
// swipe cards key
  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();
  // GlobalKey currentIndex;

  final deviceId;
  final cookieName;
  final List oldData;
  _QuizPageState(this.deviceId, this.cookieName, this.oldData) : super();

//LinearProgressIndicator methods

  double _progress = 0.33;

// to aviod meomory leak
  @override
  void dispose() {
    controller.dispose();
    _incrementCurrentIndex();
    _decrementCurrentIndex();
    super.dispose();
  }

  @override
  void didUpdateWidget(QuizPage oldWidget) {
    _incrementCurrentIndex();
    _decrementCurrentIndex();
    super.didUpdateWidget(oldWidget);

    print('didUpdateWidget');
  }

//animation fucntions
  Animation<Offset> animation;
  AnimationController controller;
  double beginAnim = 0.0;
  double endAnim = 1.0;
  startProgress() {
    controller.forward();
  }

  stopProgress() {
    controller.stop();
  }

  resetProgress() {
    controller.reset();
  }

  reserveProgress() {
    print(currentIndex);

    controller.reverse();
  }

  @override
  void initState() {
    this._getItemsFromLocalStorage();
    this._checkOldData();
    this._getQuestions();
    this._getAnswers();
    this.fetchQuestions();
    this.fetchAnswers();
    controller =
        AnimationController(duration: const Duration(seconds: 2), vsync: this);

    super.initState();
  }

  //localStorage functions

  static final v1 = 'ibdaa';

// get questions and answers from localStorage
  final AnswersList list1 = new AnswersList();

// Save and Delete data from Local Storage
  final LocalStorage storage = new LocalStorage(v1);
  bool initialized = false;

  List dataListWithCookieName;

  _checkOldData() {
    setState(() {
      dataListWithCookieName = oldData;
    });
    var findEmpty = dataListWithCookieName.contains('empty');

    switch (findEmpty) {
      case true:
        setState(() {
          dataListWithCookieName = null;
        });
        break;
      case false:
        setState(() {
          dataListWithCookieName = oldData;
        });
    }
  }

  _addItem(int id, String answersText, double answerValue) async {
    //save the old items in the new list

    setState(() {
      final item = new GetAnswers(
          id: id, answersText: answersText, answerValue: answerValue);
      list1.items.add(item);
      dataListWithCookieName.add(item);

      storage.setItem("$cookieName", dataListWithCookieName);
    });
  }

  _clearStorage() async {
    await storage.clear();

    setState(() {
      list1.items = storage.getItem("$deviceId") ?? [];
    });
  }

  //// Get the existing data
  ///
  ///
  int currentIndex = 0;

  // Get questions From the server

  var listQuestions = new List<GetQuestions>();

  _getQuestions() async {
    new Future.delayed(const Duration(seconds: 3));

    await API.getQuestions().then((response) {
      setState(() {
        Iterable list = json.decode(response.body)['result'];
        listQuestions =
            list.map((model) => GetQuestions.fromJson(model)).toList();
      });
    });
  }

  List questionsListTest = [];

  Future<List<dynamic>> fetchQuestions() async {
    var result = await http.get('http://localhost:3000/questions/list');

    setState(() {
      questionsListTest = json.decode(result.body)['result'];
    });
    return json.decode(result.body)['result'];
  }

//Get answers From the serve
  var listAnswers = new List<GetAnswers>();
  List answersList = [];

  Future<List<dynamic>> fetchAnswers() async {
    var result = await http.get('http://localhost:3000/answers/list');

    setState(() {
      answersList = json.decode(result.body)['result'];
    });
    return json.decode(result.body)['result'];
  }

  _getAnswers() async {
    new Future.delayed(const Duration(seconds: 3));

    await API.getAnswers().then((response) {
      setState(() {
        Iterable list = json.decode(response.body)['result'];
        listAnswers = list.map((model) => GetAnswers.fromJson(model)).toList();
      });
    });
  }

  // get Items from localStorageand
  // This function for checking  and count the items inside the local storage and it  return the NEW currentIndex

  _getItemsFromLocalStorage() async {
    setState(() {
      dataListWithCookieName = oldData;
    });
    var findEmpty = dataListWithCookieName.contains('empty');
    if (findEmpty) {
      setState(() {
        currentIndex = 0;
      });
    } else {
      setState(() {
        currentIndex = dataListWithCookieName.length;
      });
    }
    return currentIndex;
  }

  returnButtonFunction() async {
    final Storage _localStorage = window.localStorage;

    List removeItemFromLocalStorageList = [];
    var items = _localStorage['ibdaa'];

    final decoding = json.decode(items);
    var getData = decoding['$deviceId'];

    print(getData.length + 1);

    setState(() {
      removeItemFromLocalStorageList = getData;
    });

    int deleteCurrentIndex = currentIndex - 1;
    await pop(removeItemFromLocalStorageList);

    await storage.deleteItem('ibdaa');
    storage.setItem("$cookieName", removeItemFromLocalStorageList);

    print(
        "deleted array $removeItemFromLocalStorageList +++ currentIndex $deleteCurrentIndex  ");

    _decrementCurrentIndex();

    if (getData == []) {
      return false;
    }
    print('from the return button function $currentIndex');
  }

  // seState functions
  _incrementCurrentIndex() {
    setState(() {
      if (currentIndex < 3) {
        currentIndex++;
      }
    });
  }

  _decrementCurrentIndex() {
    if (currentIndex != 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  /////////
  //Answers function

  answersCallBack(item) {
    final Storage _localStorage = window.localStorage;
    var items = _localStorage['ibdaa'];
    final decoding = json.decode(items);
    var getData = decoding['$deviceId'];
    if (currentIndex != 0) {
      setState(() {
        currentIndex = getData.length;
      });
    }
    _addItem(
      item.id,
      item.answersText,
      item.answerValue,
    );
    startProgress();
    _incrementCurrentIndex();
    if (currentIndex == 3) {
      Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SubmitPage(),
          ));
    }
    setState(() {
      _progress = (_progress + 0.333);
    });
    print('from _addItem function $currentIndex');
  }

  /// new design for stack
  /// //
  ///
  ///
  ///
  Widget indexStacked() {
    return Expanded(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.3,
        width: MediaQuery.of(context).size.width * 0.4,
        child: new AnimatedSwitcher(
          duration: const Duration(seconds: 2),
          transitionBuilder: (Widget child, Animation animation) {
            return SlideTransition(
              child: child,
              position:
                  Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero)
                      .animate(animation),
            );
          },
          child: Expanded(
              child: IndexedStack(
                  index: currentIndex,
                  children: questionsListTest.map((question) {
                    if (questionsListTest.indexOf(question) <= 3) {
                      // print(question.question_data);
                      return Card(
                        child: Text(question['question_data']),
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  }).toList())),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("here from the scaffold widget $currentIndex");
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Quiz"),
      ),
      body: Material(
        child: Container(
            key: UniqueKey(),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [Colors.deepPurpleAccent, Colors.tealAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 1.0],
                    tileMode: TileMode.clamp)),
            child: Column(
              children: <Widget>[
                // questions widget
                // Container(
                //   height: MediaQuery.of(context).size.height * 0.5,
                //   width: MediaQuery.of(context).size.width * 0.5,
                //   alignment: Alignment.center,
                //   child: QuestionsSwipeCards(
                //     currentIndex: currentIndex,
                //     questionsListTest: questionsListTest,
                //     swipeKey: _swipeKey,
                //   ),
                // ),
                indexStacked(),
                //answers widget

                for (var item in listAnswers)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      RaisedButton(
                          onPressed: () async {
                            // if (item.answerValue <= 0.33) {
                            //   await swipeKey.currentState.swipeLeft();
                            // } else {
                            //   await swipeKey.currentState.swipeLeft();
                            // }
                            answersCallBack(item);
                          },
                          child: Text("${item.answersText}")),
                      // _getLocalItems()
                      // LinearProgressIndicator()
                    ],
                  ),
                // AnswersButtons(
                //     swipeKey: _swipeKey,
                //     answersList: answersList,
                //     answersCallBack: answersCallBack,
                //     item: item,
                //     currentIndex: currentIndex),

                // return button
                RaisedButton(
                  onPressed: () => {
                    if (currentIndex == 0)
                      {print('object')}
                    else
                      {
                        // _swipeKey.currentState.rewind(),
                        returnButtonFunction(),
                      }
                  },
                  child: Text("return", style: TextStyle(fontSize: 20)),
                )
              ],
            )),
      ),
    );
  }
}