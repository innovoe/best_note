import 'dart:async';
import 'dart:convert';
import 'package:best_note/model/calculative_model.dart';
import 'package:best_note/model/calculative_note_bloc.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:rxdart/rxdart.dart';

class CalculativeMultipleBloc{

  List<CalculativeNoteChart> calculativeNoteList = [];

  final _calculativeMultipleController = BehaviorSubject<List<CalculativeNoteChart>>();

  final _totalSumNumbers = BehaviorSubject<double>();

  //getters
  Stream<List<CalculativeNoteChart>> get calculativeMultipleStream => _calculativeMultipleController.stream;
  StreamSink<List<CalculativeNoteChart>> get calculativeMultipleSink => _calculativeMultipleController.sink;

  Stream<double> get totalSumNumbersStream => _totalSumNumbers.stream;
  StreamSink<double> get totalSumNumbersSink => _totalSumNumbers.sink;

  void sumAllNumbers(){
    double total = 0;
    for(CalculativeNoteChart calculativeNoteChart in calculativeNoteList){
      total += calculativeNoteChart.calculativeBloc.sumTotal;
    }
    _totalSumNumbers.add(total);
  }

  bool checkLast(){
    String totalText = '';
    CalculativeNoteChart calculativeNoteChart = calculativeNoteList.last;
    List<CalculativeModel> calculativeList = calculativeNoteChart.calculativeBloc.calculativeList;
    for(CalculativeModel calculativeModel in calculativeList){
      totalText += calculativeModel.subjectController.text.trim();
      totalText += calculativeModel.numberController.text.trim();
    }
    return (totalText == '') ? false : true;
  }

  void addFirstNew(){
    Uuid uuid = Uuid();
    String id = uuid.v1();
    CalculativeNoteChart calculativeNoteChart = CalculativeNoteChart(id: id, deleteNote: deleteNote, sumAllNumbers: sumAllNumbers);
    calculativeNoteList.insert(calculativeNoteList.length, calculativeNoteChart);
    _calculativeMultipleController.add(calculativeNoteList);
  }

  bool addNew(){
    if(checkLast()){
      Uuid uuid = Uuid();
      String id = uuid.v1();
      CalculativeNoteChart calculativeNoteChart = CalculativeNoteChart(id: id, deleteNote: deleteNote, sumAllNumbers: sumAllNumbers);
      calculativeNoteList.insert(calculativeNoteList.length, calculativeNoteChart);
      _calculativeMultipleController.add(calculativeNoteList);
      return true;
    }else{
      return false;
    }
  }

  CalculativeNoteChart calculativeNoteChart(){
    Uuid uuid = Uuid();
    String id = uuid.v1();
    return CalculativeNoteChart(
        id: id,
        deleteNote: deleteNote,
        sumAllNumbers: sumAllNumbers
    );
  }

  void deleteNote(String id){
    calculativeNoteList.removeWhere((CalculativeNoteChart calculativeNoteChart){
      if(calculativeNoteChart.id == id){
        // calculativeNoteChart.calculativeBloc.dispose();
        return true;
      }else{
        return false;
      }
    });
    sumAllNumbers();
    _calculativeMultipleController.add(calculativeNoteList);
  }

  void dispose(){
    _calculativeMultipleController.close();
  }

  String jsonStringBuild(){
    String jsonOut = '{';
    int chartIndex = 0;
    for(CalculativeNoteChart calculativeNoteChart in calculativeNoteList){
      List calculativeList = calculativeNoteChart.calculativeBloc.calculativeList;
      String chart = '"$chartIndex" : [';
      int index = 0;
      for(CalculativeModel calculativeModel in calculativeList){
        Map singleEntry = {};
        singleEntry['subject'] = calculativeModel.subjectController.text;
        singleEntry['number'] = calculativeModel.numberController.text;
        singleEntry['type'] = calculativeModel.type;
        String singleEntryJson = json.encode(singleEntry);
        chart += (index == 0) ? singleEntryJson : ',$singleEntryJson';
        index++;
      }
      chart += ']';
      jsonOut += (chartIndex == 0) ? chart : ',$chart';
      chartIndex++;
    }
    jsonOut += '}';
    return jsonOut;
  }

  bool checkNoteEmpty(){
    String jsonOut = '';
    for(CalculativeNoteChart calculativeNoteChart in calculativeNoteList){
      List calculativeList = calculativeNoteChart.calculativeBloc.calculativeList;

      for(CalculativeModel calculativeModel in calculativeList){
        jsonOut += calculativeModel.subjectController.text;
        jsonOut += calculativeModel.numberController.text;
      }
    }
    return (jsonOut == '') ? true : false;
  }

}

class CalculativeNoteChart{
  final String id;
  Function(String) deleteNote;
  VoidCallback sumAllNumbers;
  late CalculativeNoteBloc calculativeBloc;

  CalculativeNoteChart({required this.id, required this.deleteNote, required this.sumAllNumbers}){
    calculativeBloc = CalculativeNoteBloc(sumAllNumbers: sumAllNumbers);
  }



  Widget noteChart(){
    Widget newNote = StreamBuilder<List<CalculativeModel>>(
        stream: calculativeBloc.calculativeListStream,
        builder: (context, snapshot){
          if(snapshot.hasError){
            return Text('error:  ${snapshot.error.toString()})');
          }else if(snapshot.hasData){
            List<CalculativeModel> rows = snapshot.data as List<CalculativeModel>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Stack(
                children: [
                  Column(
                    children: rows.map((row) => row.calculativeRow()).toList(),
                  ),
                  Positioned(
                    top: -5,
                    right: -5,
                    child: GestureDetector(
                      onLongPress: () => deleteNote(id),
                      child: CircleAvatar(radius: 13, backgroundColor: Colors.grey ,child: Icon(Icons.close)),
                    ),
                  ),
                ],
              ),
            );
          }else{
            return CircularProgressIndicator();
          }
        }
    );
    return newNote;
  }
}