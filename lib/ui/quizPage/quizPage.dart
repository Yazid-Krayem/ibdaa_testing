import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:ibdaa_testing/models/answersList.dart';
import 'package:ibdaa_testing/models/api.dart';
import 'package:ibdaa_testing/models/getAnswers.dart';
import 'package:ibdaa_testing/models/getQuestions.dart';
import 'package:http/http.dart' as http;
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
    this.fetchUsers();
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

  List dataListWithCookieName = [];

  _checkOldData() {
    setState(() {
      dataListWithCookieName = oldData;
    });
    var findEmpty = dataListWithCookieName.contains('empty');
    if (findEmpty) {
      setState(() {
        dataListWithCookieName = [];
      });
    } else {
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

  // _saveToStorage() {
  //   storage.setItem("$deviceId", list1.toJSONEncodable());
  // }

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

  Future<List<dynamic>> fetchUsers() async {
    var result = await http.get('http://localhost:3000/questions/list');

    setState(() {
      questionsListTest = json.decode(result.body)['result'];
    });
    return json.decode(result.body)['result'];
  }

//Get answers From the serve
  var listAnswers = new List<GetAnswers>();
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
    print(_currentIndex);
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

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Quiz"),
      ),
      body: Container(
          padding: const EdgeInsets.only(top: 16.0),
          child: Stack(
            children: [
              SwipeStack(
                  key: _swipeKey,
                  children: questionsListTest.map((index) {
                    return SwiperItem(
                        builder: (SwiperPosition position, double progress) {
                      return Material(
                          elevation: 4,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(index['question_data'],
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 20)),
                                  Text("Progress $position",
                                      style: TextStyle(
                                          color: Colors.blue, fontSize: 12)),
                                ],
                              )));
                    });
                  }).toList(),
                  animationDuration: Duration(seconds: 2),
                  historyCount: 3,
                  visibleCount: 3,
                  stackFrom: StackFrom.Top,
                  translationInterval: 6,
                  scaleInterval: 0.03,
                  onSwipe: (int index, SwiperPosition position) => {
                        if (SwiperPosition.Right != null)
                          {print('right')}
                        else if (SwiperPosition.Left != null)
                          {print('left')}
                      },
                  onEnd: () => debugPrint("onEnd"),
                  onRewind: (int index, SwiperPosition position) =>
                      SwiperPosition.None),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  RaisedButton(
                    onPressed: () => {_swipeKey.currentState.swipeRight()},
                    child: Text('swipe right'),
                  ),
                  RaisedButton(
                    onPressed: () => {_swipeKey.currentState.swipeLeft()},
                    child: Text('swipe left'),
                  ),
                  RaisedButton(
                    onPressed: () => {_swipeKey.currentState.rewind()},
                    child: Text('swipe rewind'),
                  ),
                ],
              )
            ],
          )),
    );
  }
}
