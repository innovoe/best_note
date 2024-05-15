import 'dart:async';
import 'package:best_note/model/calculative_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class CalculativeNoteBloc{

  //list of calculative_models
  List<CalculativeModel> calculativeList = [];

  double sumTotal = 0;
  VoidCallback sumAllNumbers;

  CalculativeNoteBloc({required this.sumAllNumbers}){
    calculativeList = [
      CalculativeModel(id:'', subjectValue: '', numberValue: '',addRow: addNewRow, valueChanged:(){}, delete:deleteRow, type: 3),
      CalculativeModel(id:'', subjectValue: '', numberValue: '', addRow: addNewRow, valueChanged:(){}, delete:deleteRow, type: 2),
    ];
    addNewRow();
  }

  //Stream Controller
  final _calculativeListStreamController = BehaviorSubject<List<CalculativeModel>>();

  //getters
  Stream<List<CalculativeModel>> get calculativeListStream => _calculativeListStreamController.stream;
  StreamSink<List<CalculativeModel>> get calculativeListSink => _calculativeListStreamController.sink;

  void addNewRow(){
    Uuid uuid = Uuid();
    String rowId = uuid.v1();
    CalculativeModel calculativeModel = CalculativeModel(
        id: rowId,
        subjectValue: '',
        numberValue: '',
        addRow: (){},
        valueChanged: sumNumbers,
        delete: (rowId) => deleteRow(rowId)
    );
    // calculativeList.add(calculativeModel);
    calculativeList.insert(calculativeList.length - 1, calculativeModel);
    _calculativeListStreamController.add(calculativeList);
  }

  CalculativeModel calculativeModel(String subjectValue, String numberValue, int type){
    Uuid uuid = Uuid();
    String rowId = uuid.v1();
    return CalculativeModel(
      id: rowId,
      subjectValue: subjectValue,
      numberValue: numberValue,
      valueChanged: sumNumbers,
      addRow: (type == 1) ? (){} : addNewRow,
      delete: (rowId) => deleteRow(rowId),
      type: type
    );
  }

  // void addLoadedData(List<CalculativeModel> calculativeModelList){
  //   calculativeList = calculativeModelList;
  //   _calculativeListStreamController.add(calculativeList);
  // }

  void sumNumbers(){
    double total = 0;
    for(int i = 1; i < calculativeList.length - 1 ; i++){
      String valueString = calculativeList[i].numberController.text;
      valueString = valueString.trim();
      if(valueString == ''){
        valueString = '0';
      }
      double value = double.parse(valueString);
      total += value;
    }
    sumTotal = total;
    calculativeList.last.numberController.text = total.toString();
    _calculativeListStreamController.add(calculativeList);
    sumAllNumbers();
  }

  void deleteRow(String id){
    calculativeList.removeWhere((CalculativeModel calculativeModel){
      if(calculativeModel.id == id){
        calculativeModel.subjectController.dispose();
        calculativeModel.numberController.dispose();
        return true;
      }else{
        return false;
      }
    });
    sumNumbers();
    _calculativeListStreamController.add(calculativeList);
  }

  //dispose
  dispose(){
    _calculativeListStreamController.close().whenComplete((){
      for(CalculativeModel calculativeModel in calculativeList){
        calculativeModel.dispose();
      }
    });
  }
}