import 'dart:convert';
import 'package:best_note/model/bloc.dart';
import 'package:best_note/model/calculative_model.dart';
import 'package:best_note/model/calculative_multiple_bloc.dart';
import 'package:best_note/model/calculative_note_bloc.dart';
import 'package:best_note/model/home_page_note_list.dart';
import 'package:best_note/model/load_data.dart';
import 'package:best_note/model/save_data.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CalculativeNote extends StatefulWidget {
  const CalculativeNote({Key? key}) : super(key: key);

  @override
  State<CalculativeNote> createState() => _CalculativeNoteState();
}

class _CalculativeNoteState extends State<CalculativeNote> {
  CalculativeMultipleBloc calculativeMultipleBloc = CalculativeMultipleBloc();
  late TextEditingController titleController;
  String noteName = DateTime.now().millisecondsSinceEpoch.toString();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    titleController = TextEditingController();

    if(bloc.name == 'none'){
      calculativeMultipleBloc.addFirstNew();
    }else{
      LoadData loader = LoadData(bloc.name);
      loader.loadJsonFromName().then((loadedJson) => loadCalculativeNoteFromJson(loadedJson));
      loader.loadInfoFromName().then((loadedInfo) => setTitleText(loadedInfo));
      noteName = bloc.name;
    }
  }


  @override
  Widget build(BuildContext context) {
    // HomePageNoteList homePageNoteList = Provider.of<HomePageNoteList>(context);
    return WillPopScope(
      onWillPop: () async{
        bool jsonPassed = await save();
        FocusManager.instance.primaryFocus?.unfocus();
        await Future.delayed(const Duration(milliseconds: 500), (){});
        homePageNoteList.getNoteNames();
        return jsonPassed;
      },
      child: Scaffold(
        body: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            iconTheme: IconThemeData(
              color: Colors.black87, //change your color here
            ),
            elevation: 0,
            backgroundColor: Colors.white70,
            title: titleTextField(),
            actions: [
              IconButton(
                icon: Icon(Icons.save),
                onPressed: () => save(),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              child: StreamBuilder<List<CalculativeNoteChart>>(
                stream: calculativeMultipleBloc.calculativeMultipleStream,
                builder: (context, snapshot){
                  if(snapshot.hasError){
                    return Text('error:  ${snapshot.error.toString()})');
                  }else if(snapshot.hasData && snapshot.connectionState == ConnectionState.active){
                    List<CalculativeNoteChart> rows = snapshot.data as List<CalculativeNoteChart>;
                    return Column(
                      children: rows.map((CalculativeNoteChart calculativeNoteChart) => calculativeNoteChart.noteChart()).toList(),
                    );
                  }else{
                    return CircularProgressIndicator();
                  }
                }),
              ),
          ),
          bottomNavigationBar: Container(
            height: 60,
            color: Colors.white70,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StreamBuilder<double>(
                    stream: calculativeMultipleBloc.totalSumNumbersStream,
                    builder: (context, snapshot){
                      if(snapshot.hasError){
                        return Text('error ${snapshot.error.toString()}');
                      }else if(snapshot.hasData){
                        return Text('GT ${snapshot.data.toString()}', style: TextStyle(color: Colors.purple, fontSize: 20, fontWeight: FontWeight.bold),);
                      }else{
                        return Text('GT 0', style: TextStyle(color: Colors.purple, fontSize: 20, fontWeight: FontWeight.bold),);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: (){
                      calculativeMultipleBloc.addNew() ? '' : alertUnusedTableFound();
                    },
                    color: Colors.blueAccent,
                  ),

                ],
              ),
            ),
          )
        ),
      ),
    );
  }

  //title
  Widget titleTextField(){
    return TextFormField(
        controller: titleController,
        style: TextStyle(
          fontSize: 24,
          color: Colors.grey[800],
        ),
        maxLines: null,
        autofocus: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Type Title Here',
        )
    );
  }

  void setTitleText(String loadedInfo){
    var jsonDecoded = jsonDecode(loadedInfo);
    titleController.text = jsonDecoded['title'];
  }

  void loadCalculativeNoteFromJson(String jsonString){
    List<CalculativeNoteChart> calculativeNoteList = [];
    Map<String, dynamic> jsonDecodedCalculative = jsonDecode(jsonString);
    jsonDecodedCalculative.forEach((key, value) {
      CalculativeNoteChart calculativeNoteChart = calculativeMultipleBloc.calculativeNoteChart();
      CalculativeNoteBloc calculativeNoteBloc = calculativeNoteChart.calculativeBloc;
      List<CalculativeModel> calculativeList = [];
      for(Map<String, dynamic> jd in value){
        CalculativeModel calculativeModel = calculativeNoteBloc.calculativeModel(
          jd['subject'],
          jd['number'],
          jd['type']
        );
        calculativeList.add(calculativeModel);

      }
      calculativeNoteBloc.calculativeList = calculativeList;
      calculativeNoteBloc.sumNumbers();
      calculativeNoteBloc.calculativeListSink.add(calculativeList);
      calculativeNoteList.add(calculativeNoteChart);
    });
    calculativeMultipleBloc.calculativeNoteList = calculativeNoteList;
    calculativeMultipleBloc.calculativeMultipleSink.add(calculativeNoteList);
    calculativeMultipleBloc.sumAllNumbers();
  }

  String buildInfoJson(){
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime dateTimeTimeStamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var info = {};
    info['title'] = titleController.text;
    info['date'] = dateTimeTimeStamp.toString();
    info['type'] = '1';
    String infoJson = json.encode(info);

    return infoJson;
  }

  Future<bool> save() async{
    if(titleController.text == '' && calculativeMultipleBloc.checkNoteEmpty() == true){
      return true;
    }
    SaveData saveData = SaveData(noteName: noteName, jsonString: calculativeMultipleBloc.jsonStringBuild(), infoJson: buildInfoJson());
    saveData.save();
    return saveData.checkJsonFormat();
  }

  alertUnusedTableFound(){
    return Alert(
      buttons: [
        DialogButton(child: Text('Got It'), onPressed: () => Navigator.pop(context)),
      ],
      type: AlertType.warning,
      context: context,
      title: 'Unused Table Found!',
      desc: 'You Last added table is still unused. Add data to it for adding more tables.',
    ).show();
  }
}
