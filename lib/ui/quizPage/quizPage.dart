import 'dart:convert';
import 'dart:html';
import 'package:flutter/material.dart';
import 'package:ibdaa_testing/models/answersList.dart';
import 'package:ibdaa_testing/models/api.dart';
import 'package:ibdaa_testing/models/getAnswers.dart';
import 'package:ibdaa_testing/models/getQuestions.dart';
import 'package:http/http.dart' as http;
import 'package:ibdaa_testing/ui/answersButtons/answersButtons.dart';
import 'package:ibdaa_testing/ui/questionsList/questionsList.dart';
import 'package:ibdaa_testing/ui/submitPage/submitPage.dart';
import 'package:js_shims/js_shims.dart';
import 'package:localstorage/localstorage.dart';

import '../style.dart';

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
    returnButtonFunction().dispose();
    _incrementCurrentIndex().dispose();
    _decrementCurrentIndex().dispose();
    super.dispose();
  }

//animation fucntions
  Animation<double> animation;
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
    animation = Tween(begin: beginAnim, end: endAnim).animate(controller)
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
  final LocalStorage progressStorage = new LocalStorage('progress');
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
    // print('_additem $dataListWithCookieName');
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

  final url = 'https://ibdaa.herokuapp.com';

  Future<List<dynamic>> fetchQuestions() async {
    var result = await http.get(
      '$url/questions/list',
      headers: {
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        "Access-Control-Allow-Credentials":
            'true', // Required for cookies, authorization headers with HTTPS
        "Access-Control-Allow-Headers":
            "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "POST, OPTIONS"
      },
    );

    setState(() {
      questionsListTest = json.decode(result.body)['result'];
    });
    return json.decode(result.body)['result'];
  }

//Get answers From the serve
  var listAnswers = new List<GetAnswers>();
  List answersList = [];

  Future<List<dynamic>> fetchAnswers() async {
    var result = await http.get(
      '$url/answers/list',
      headers: {
        "Access-Control-Allow-Origin": "*", // Required for CORS support to work
        "Access-Control-Allow-Credentials":
            'true', // Required for cookies, authorization headers with HTTPS
        "Access-Control-Allow-Headers":
            "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
        "Access-Control-Allow-Methods": "POST, OPTIONS"
      },
    );

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
    final Storage _localStorage = window.localStorage;
    var items = _localStorage['progress'];
    final decoding = json.decode(items);

    final progressLocalStorage = decoding['progress'];

    setState(() {
      dataListWithCookieName = oldData;
    });
    var findEmpty = dataListWithCookieName.contains('empty');
    if (findEmpty) {
      setState(() {
        currentIndex = 0;
        _progress = 0.33;
      });
    } else {
      setState(() {
        currentIndex = dataListWithCookieName.length;
        _progress = progressLocalStorage;
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

    setState(() {
      removeItemFromLocalStorageList = getData;
      removeItemFromLocalStorageList = dataListWithCookieName;
    });

    // int deleteCurrentIndex = currentIndex - 1;
    await pop(removeItemFromLocalStorageList);

    await storage.deleteItem('ibdaa');
    storage.setItem("$cookieName", removeItemFromLocalStorageList);

    // print("deleted array $removeItemFromLocalStorageList +++ currentIndex $deleteCurrentIndex  ");

    _decrementCurrentIndex();

    if (getData == []) {
      return false;
    }
    // print('from the return button function $currentIndex');
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
        _progress = _progress - 0.33;
      });
      progressStorage.setItem("progress", _progress);
    }
  }

  /////////
  //Answers function

  answersCallBack(item) {
    if (currentIndex != 0) {
      final Storage _localStorage = window.localStorage;
      var items = _localStorage['ibdaa'];
      final decoding = json.decode(items);
      var getData = decoding['$deviceId'];
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
            builder: (BuildContext context) => SubmitPage(
                deviceId: deviceId, questionsListTest: questionsListTest),
          ));
    }
    setState(() {
      _progress = (_progress + 0.333);
    });

    progressStorage.setItem("progress", _progress);
  }

  /// new design for stack
  /// //
  ///
  ///
  ///
  Widget indexStacked() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Container(
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.height * 0.3,
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue],
              ),
            ),
            child: IndexedStack(
                index: currentIndex,
                children: questionsListTest.map((question) {
                  if (questionsListTest.indexOf(question) <= 3) {
                    // print(question.question_data);
                    return QuestionsList(
                        currentIndex: currentIndex,
                        progress: _progress,
                        question: question);
                  } else {
                    return Container();
                  }
                }).toList()),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Quiz"),
      ),
      body: SingleChildScrollView(
        child: Material(
          child: Container(
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
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Center(
                    child: indexStacked(),
                  ),
                  // //answers widget

                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxHeight < 768 &&
                          constraints.maxWidth < 420) {
                        return _answersButtonColumn();
                      } else {
                        return _answersButtonRow();
                      }
                    },
                  ),
                  // Row(
                  //   crossAxisAlignment: CrossAxisAlignment.end,
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     for (var item in listAnswers)
                  //       Container(
                  //         padding: const EdgeInsets.only(bottom: 150.0),
                  //         alignment: Alignment.bottomCenter,
                  //         child: AnswersButtons(
                  //             answersList: answersList,
                  //             answersCallBack: answersCallBack,
                  //             item: item,
                  //             currentIndex: currentIndex),
                  //       ),
                  //   ],
                  // ),

                  // return button
                  Container(
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.all(20.0),
                    child: RaisedButton(
                      shape: buttonStyle,
                      textColor: Colors.black,
                      color: Colors.blue,
                      onPressed: () => {
                        if (currentIndex == 0)
                          {print('object')}
                        else
                          {
                            returnButtonFunction(),
                          }
                      },
                      child: Text("return", style: TextStyle(fontSize: 20)),
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }

  _answersButtonRow() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var item in listAnswers)
              Container(
                padding: const EdgeInsets.only(bottom: 150.0),
                alignment: Alignment.bottomCenter,
                child: AnswersButtons(
                    answersList: answersList,
                    answersCallBack: answersCallBack,
                    item: item,
                    currentIndex: currentIndex),
              )
          ],
        )
      ],
    );
  }

  _answersButtonColumn() {
    return Container(
      height: 300,
      padding: const EdgeInsets.only(top: 60.0),
      alignment: Alignment.bottomCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (var item in listAnswers)
            Wrap(children: [
              AnswersButtons(
                  answersList: answersList,
                  answersCallBack: answersCallBack,
                  item: item,
                  currentIndex: currentIndex),
            ])
        ],
      ),
    );
  }
}
