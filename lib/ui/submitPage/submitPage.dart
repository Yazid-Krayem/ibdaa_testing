import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../style.dart';

// ignore: must_be_immutable
class SubmitPage extends StatelessWidget {
  final LocalStorage storage = new LocalStorage('ibdaa');
  final LocalStorage progressStorage = new LocalStorage('progress');

  @override
  Widget build(BuildContext context) {
    // _getItemsFromLocalStorage();
    //  ITEMS holds the answer's of the user

    return Scaffold(
        body: Column(
      children: [
        Row(
          children: [
            new Container(
              child: RaisedButton(
                shape: buttonStyle,
                onPressed: () {
                  storage.clear();
                  progressStorage.clear();
                },
                child: Text('Submit'),
              ),
            ),
            new Container(
              child: RaisedButton(
                shape: buttonStyle,
                onPressed: () {
                  storage.clear();
                  progressStorage.clear();
                },
                child: Text('Share'),
              ),
            ),
          ],
        )
      ],
    ));
  }
}
