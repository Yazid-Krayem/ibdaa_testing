import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

// ignore: must_be_immutable
class SubmitPage extends StatelessWidget {
  final LocalStorage storage = new LocalStorage('ibdaa');
  final LocalStorage progressStorage = new LocalStorage('progress');

  @override
  Widget build(BuildContext context) {
    // _getItemsFromLocalStorage();
    //  ITEMS holds the answer's of the user

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Submit'),
        ),
        body: Column(
          children: [
            // for (var item in items) Center(child: questionsList(item)),
            new Container(
              child: RaisedButton(
                onPressed: () {
                  storage.clear();
                  progressStorage.clear();
                },
                child: Text('Submit'),
              ),
            ),
          ],
        ));
  }
}
