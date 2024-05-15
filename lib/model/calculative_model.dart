import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CalculativeModel{
  TextEditingController subjectController = TextEditingController();
  TextEditingController numberController = TextEditingController();

  String id;
  int type;
  final VoidCallback valueChanged;
  final VoidCallback addRow;
  final Function(String) delete;
  String subjectValue = '';
  String numberValue = '';

  CalculativeModel({
    required this.id,
    required this.subjectValue,
    required this.numberValue,
    required this.valueChanged,
    required this.addRow,
    required this.delete,
    this.type = 1
  }){
   subjectController.text = subjectValue;
   numberController.text = numberValue;
  }

  Widget subjectField(){

    return TextField(
      autofocus: (type == 1) ? true : (type == 3) ? true : false,
      controller: subjectController,
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
      ),
      enabled: (type == 1) ? true : (type == 3) ? true : false,
      decoration: InputDecoration(
        suffixIcon: (type == 2) ? Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                  padding: EdgeInsets.all(5),
                  child: Text('Total', style: TextStyle(color: Colors.black54),),
              ),
            ),
            Container(
              padding: EdgeInsets.all(2),
              child: Text('Row')
            ),
            Container(
              padding: EdgeInsets.all(2),
              child: Icon(Icons.arrow_downward_outlined, color: Colors.black,),
            ),
          ],
        ) : Opacity(child: Icon(Icons.close), opacity: 0),
        suffixIconConstraints: BoxConstraints(
          minHeight: 10,
          minWidth: 10,
        ),
        // suffixIcon: (type == 2) ? Icon(Icons.arrow_drop_down_circle) : Opacity(opacity: 0),
        hintText: (type == 1) ? 'Description' : (type == 3) ? 'Title' : 'Total',
        filled: (type == 1) ? false : true,
        fillColor: Colors.deepPurple[200],
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)
      ),
    );
  }

  Widget numberField(){
    return TextField(
      controller: numberController,
      onChanged: (String value) => valueChanged(),
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[800],
      ),
      enabled: (type == 1) ? true : false,
      decoration: InputDecoration(
        suffixIcon: (type == 1) ? GestureDetector(
          child: Container(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.close),
          ),
          onLongPress: () => delete(id),
        ) : Opacity(child: Icon(Icons.arrow_downward_outlined), opacity: 1),
        suffixIconConstraints: BoxConstraints(
          minHeight: 10,
          minWidth: 10,
        ),
        hintText: (type == 1) ? 'Amount' : '0',
        filled: (type == 1) ? false : true,
        fillColor: Colors.deepPurple[200],
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8)
      ),
      keyboardType: TextInputType.numberWithOptions(signed: true, decimal: true),
    );
  }

  Widget calculativeRow(){
    if(type == 3){
      return subjectField();
    }else if(type == 2){
      return GestureDetector(
        onTap: () => addRow(),
        child: Row(
          children: [
            Expanded(child: subjectField()),
            Expanded(child: numberField()),
          ],
        ),
      );
    }else{
      return Row(
        children: [
          Expanded(child: subjectField()),
          Expanded(child: numberField()),
        ],
      );
    }
  }

  void dispose(){
    subjectController.dispose();
    numberController.dispose();
  }

}