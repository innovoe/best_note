import 'package:flutter/material.dart';

class Note extends StatelessWidget {
  const Note({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RichText(
        text: TextSpan(
          children: [
            TextSpan(text: 'Hello this is my new pet tommy. ', style: TextStyle(color: Colors.black)),
            WidgetSpan(child: image()),
            TextSpan(text: 'Tommy is a great cat. '),
            WidgetSpan(child: image()),
            WidgetSpan(child: image()),
            TextSpan(text: 'I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. '),
            WidgetSpan(child: image()),
            TextSpan(text: 'I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. I love tommy. ')
          ]
        ),
      ),
    );
  }

  Widget image(){
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
      height: 150,
      child: Image.network('https://upload.wikimedia.org/wikipedia/commons/thumb/b/b1/VAN_CAT.png/330px-VAN_CAT.png'),
    );
  }
}
