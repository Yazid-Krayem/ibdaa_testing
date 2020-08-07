import 'package:flutter/material.dart';

class QuestionsList extends StatelessWidget {
  final item;

  const QuestionsList({
    Key key,
    @required this.item,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    print(item);
    return Card(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('${item.question_data}'),
          )
        ],
      ),
    );
  }
}
