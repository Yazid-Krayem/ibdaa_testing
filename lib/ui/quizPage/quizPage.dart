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

  QuizPage(this.deviceId, this.cookieName, this.oldData);
  @override
  _QuizPageState createState() => _QuizPageState(deviceId, cookieName, oldData);
}

class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
// swipe cards key
  final GlobalKey<SwipeStackState> _swipeKey = GlobalKey<SwipeStackState>();

  final deviceId;
  final cookieName;
  final List oldData;
  _QuizPageState(this.deviceId, this.cookieName, this.oldData);

//LinearProgressIndicator methods

  double _progress = 0.33;

// to aviod meomory leak
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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
    print(_currentIndex);

    controller.reverse();
  }

  @override
  void initState() {
    this._checkOldData();
    this._getQuestions();
    this._getAnswers();
    this.fetchQuestions();
    this.fetchAnswers();
    controller =
        AnimationController(duration: const Duration(seconds: 5), vsync: this);
    animation = Tween<Offset>(begin: Offset(0, 1), end: Offset(1, 0))
        .animate(controller)
          ..addListener(() {
            setState(() {
              // Change here any Animation object value.
            });
          });
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
  int _currentIndex = 0;

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
        _currentIndex = 0;
      });
    } else {
      setState(() {
        _currentIndex = dataListWithCookieName.length;
      });
    }
    return _currentIndex;
  }

  returnButtonFunction() async {
    final Storage _localStorage = window.localStorage;

    List removeItemFromLocalStorageList = [];
    var items = _localStorage['ibdaa'];

    final decoding = json.decode(items);
    var getData = decoding['$deviceId'];

    setState(() {
      removeItemFromLocalStorageList = getData;
    });

    int deleteCurrentIndex = _currentIndex - 1;
    await pop(removeItemFromLocalStorageList);

    // setState(() {
    //   removeItemFromLocalStorageList = test;
    // });
    await storage.deleteItem('ibdaa');
    storage.setItem("$cookieName", removeItemFromLocalStorageList);

    print(
        "deleted array $removeItemFromLocalStorageList +++ currentIndex $deleteCurrentIndex  ");

    if (_currentIndex != 0) {
      setState(() {
        _currentIndex = _currentIndex - 1;
      });
    }
  }
  //Answers function

  answersCallBack(item) {
    _addItem(
      item.id,
      item.answersText,
      item.answerValue,
    );
    startProgress();
    setState(() {
      _currentIndex = (_currentIndex + 1);
    });
    if (_currentIndex == 4) {
      Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => SubmitPage(),
          ));
    }
    setState(() {
      _progress = (_progress + 0.333);
      _currentIndex = _currentIndex++;
    });
    print(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    _getItemsFromLocalStorage();
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Quiz"),
      ),
      body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.tealAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp)),
          child: Stack(
            children: [
              //questions widget
              Align(
                alignment: Alignment.center,
                child: QuestionsSwipeCards(
                  currentIndex: _currentIndex,
                  questionsListTest: questionsListTest,
                  swipeKey: _swipeKey,
                ),
              ),

              //answers widget
              for (var item in listAnswers)
                AnswersButtons(
                  swipeKey: _swipeKey,
                  answersList: answersList,
                  answersCallBack: answersCallBack,
                  item: item,
                ),

              // return button
              Align(
                alignment: Alignment.topRight,
                child: RaisedButton(
                    onPressed: () => {
                          _swipeKey.currentState.rewind(),
                          returnButtonFunction(),
                        },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text("return", style: TextStyle(fontSize: 20)),
                        Icon(Icons.navigate_before)
                      ],
                    )),
              )
            ],
          )),
    );
  }
}
