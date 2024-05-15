import 'package:flutter/material.dart';
import 'package:best_note/model/bloc.dart';

class NoteObject{
  //required props
  final BuildContext context;
  final String id;
  final String type;

  //global props
  String fileName = '';
  String folder = '';
  bool working = false;
  //global callbacks
  late VoidCallback delete; //delete instance from list
  late VoidCallback stopGapperBlinkers; //blink only the selected gapper(value is in the bloc)
  late VoidCallback setIndex;

  //text props
  final _mnTextController = TextEditingController();
  bool focusing = false;


  NoteObject({required this.id, required this.type, required this.context});


  // Text methods start
  Widget mnInput([String setValue = '']){
    if(setValue != ''){
      _mnTextController.text = setValue;
    }
    return Focus(
      onFocusChange: (hasFocus){
        if(hasFocus){
          focusing = true;
          bloc.selected = id;
          stopGapperBlinkers();
          setIndex();
        }else{
          focusing = false;
        }
      },
      child: TextFormField(
        controller: _mnTextController,
        style: TextStyle(
          fontSize: 24,
          color: Colors.grey[800],
        ),
        maxLines: null,
        autofocus: true,
        decoration: InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }

  String mnValue(){
    return _mnTextController.text;
  }

  void setMnValue(String setText){
    _mnTextController.text = setText;
  }

  String mnValueBefore(){
    return _mnTextController.selection.textBefore(mnValue());
  }

  String mnValueAfter(){
    return _mnTextController.selection.textAfter(mnValue()).trim();
  }
  //text method end




}