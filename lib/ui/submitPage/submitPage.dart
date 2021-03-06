import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:ibdaa_testing/main.dart';
import 'package:localstorage/localstorage.dart';

import '../style.dart';

class SubmitPage extends StatefulWidget {
  final deviceId;
  final List questionsListTest;

  SubmitPage(
      {Key key, @required this.deviceId, @required this.questionsListTest})
      : super(key: key);

  @override
  _SubmitPageState createState() =>
      _SubmitPageState(deviceId, questionsListTest);
}

class _SubmitPageState extends State<SubmitPage> {
  final deviceId;
  final List questionsListTest;
  _SubmitPageState(this.deviceId, this.questionsListTest);
  ScrollController controller = ScrollController();
  bool closeTopContainer = false;
  double topContainer = 0;

  final LocalStorage storage = new LocalStorage('ibdaa');

  final LocalStorage progressStorage = new LocalStorage('progress');

  List answersData = [];
  _getLocalStorageData() async {
    var items = storage.getItem(deviceId);
    setState(() {
      answersData = items;
    });
  }

  _getAnswersResult() async {
    var resultVar =
        answersData.map((m) => m['answer_value']).reduce((a, b) => a + b);
    setState(() {
      result = resultVar;
    });
  }

  List<Widget> itemsData = [];

  List questionsAnswers = [];

  double result;
  void getPostsData() {
    List<Widget> listItems = [];
    answersData.forEach((post) {
      // if (answersData[i] == post['id'])
      listItems.add(Container(
          height: 150,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 10.0),
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      post["answers_text"],
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          )));
    });
    setState(() {
      itemsData = listItems;
    });
  }

  @override
  void initState() {
    this._getLocalStorageData();
    getPostsData();
    controller.addListener(() {
      double value = controller.offset / 119;

      setState(() {
        topContainer = value;
        closeTopContainer = controller.offset > 50;
      });
    });
    this._getAnswersResult();

    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
    super.initState();
  }

//Alert
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Mabrouk "),
          content: new Text("Your result is $result"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Sahre it "),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: new Text("Start over "),
              onPressed: () {
                storage.clear();
                progressStorage.clear();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => MyApp()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  //speedDial Buttons

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  ScrollController scrollController;
  bool dialVisible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Submit"),
        ),
        floatingActionButton: buildSpeedDial(),
        body: SafeArea(
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
          child: Column(children: [
            Expanded(
                child: ListView.builder(
                    controller: controller,
                    itemCount: itemsData.length,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      double scale = 1.0;
                      if (topContainer > 0.5) {
                        scale = index + 0.5 - topContainer;
                        if (scale < 0) {
                          scale = 0;
                        } else if (scale > 1) {
                          scale = 1;
                        }
                      }
                      return Opacity(
                        opacity: scale,
                        child: Transform(
                          transform: Matrix4.identity()..scale(scale, scale),
                          alignment: Alignment.bottomCenter,
                          child: Align(
                              heightFactor: 0.7,
                              alignment: Alignment.topCenter,
                              child: itemsData[index]),
                        ),
                      );
                    })),
          ]),
        )));
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_arrow,
      animatedIconTheme: IconThemeData(size: 22.0),
      // child: Icon(Icons.add),
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.save, color: Colors.white),
          backgroundColor: Colors.deepOrange,
          onTap: () => _showDialog(),
          label: 'Submit',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.deepOrangeAccent,
        ),
        SpeedDialChild(
          child: Icon(Icons.share, color: Colors.white),
          backgroundColor: Colors.green,
          onTap: () => print('Share'),
          label: 'Share',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
          labelBackgroundColor: Colors.green,
        ),
      ],
    );
  }
}
