import 'package:flutter/material.dart';

class TextFieldGenerator{

  final TextEditingController _mnController = TextEditingController();


  Widget mnInput(){
    return TextFormField(
      controller: _mnController,
      style: TextStyle(
        fontSize: 24,
        color: Colors.grey[800],
      ),
      // maxLines: null,
      decoration: InputDecoration(
        // border: InputBorder.none,
      ),
    );
  }

  String mnValue(){
    return _mnController.text;
  }

}