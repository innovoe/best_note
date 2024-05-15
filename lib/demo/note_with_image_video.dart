import 'dart:convert';
import 'package:best_note/model/home_page_note_list.dart';
import 'package:best_note/model/load_data.dart';
import 'package:best_note/model/save_data.dart';
import 'package:flutter/material.dart';
import 'package:best_note/model/media_generator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:best_note/model/bloc.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:uuid/uuid.dart';

class NoteWithImageVideo extends StatefulWidget {
  const NoteWithImageVideo({Key? key}) : super(key: key);
  @override
  _NoteWithImageVideoState createState() => _NoteWithImageVideoState();
}

class _NoteWithImageVideoState extends State<NoteWithImageVideo> with WidgetsBindingObserver{
  //required lists
  List<Widget> mediaList = [];
  List<MediaGenerator> mediaGens = [];
  String debuggerString = '';
  String savingPrivateJson = '';
  late TextEditingController titleController;
  String noteName = DateTime.now().millisecondsSinceEpoch.toString();
  


  @override
  void dispose() async {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    if(state == AppLifecycleState.paused){
      // save();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    titleController = TextEditingController();
    if(bloc.name == 'none'){
      //init first text field
      String idInit = Uuid().v1();
      MediaGenerator firstOne = MediaGenerator(id: idInit, type: 'text', context: context);
      mediaList.add(firstOne.mnInput()); //array push
      mediaGens.add(firstOne); //array push
      firstOne.stopGapperBlinkers = (){
        stopGapperBlinkers();
      };
      firstOne.setIndex = (){
        setIndex();
      };
    }else{
      LoadData loader = LoadData(bloc.name);
      loader.loadJsonFromName().then((loadedJson) => loadMediaGeneratorFromJson(loadedJson));
      loader.loadInfoFromName().then((loadedInfo) => setTitleText(loadedInfo));
      noteName = bloc.name;
    }

  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wrapList = mediaList;
    return WillPopScope(
      onWillPop: () async{
        if(workingBackground()){
          alertWorking();
          return false;
        }else{
          bool jsonPassed = await save();
          FocusManager.instance.primaryFocus?.unfocus();
          await Future.delayed(const Duration(milliseconds: 500), (){});
          homePageNoteList.getNoteNames();
          return jsonPassed;
        }
      },
      child: GestureDetector(
        onTap: () => baseGestureDetector(),
        child: Scaffold(
          body: Scaffold(
            appBar: AppBar(
              iconTheme: IconThemeData(
                color: Colors.black87, //change your color here
              ),
              elevation: 0,
              backgroundColor: Colors.white70,
              title: titleTextField(),
              actions: [
                IconButton(
                  icon: Icon(Icons.save),
                  onPressed: (){
                    save();
                  },
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [

                    Wrap(
                      children: wrapList,
                    ),
                    GestureDetector(
                      onTap: (){
                        invisibleBoxTextGenBottom();
                      },
                      child: Container(
                        color: Colors.white10,
                        height: 100,
                      ),
                    )
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              height: 60,
              color: Colors.white70,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.add_a_photo),
                    onPressed: (){
                      imageGen('image', ImageSource.camera);
                    },
                    color: Colors.blueAccent,
                  ),
                  IconButton(
                    icon: Icon(Icons.add_photo_alternate),
                    onPressed: (){
                      imageGen('image', ImageSource.gallery);
                    },
                    color: Colors.blueAccent,
                  ),
                  IconButton(
                    icon: Icon(Icons.videocam),
                    onPressed: (){
                      videoGen('video', ImageSource.camera);
                    },
                    color: Colors.blueAccent,
                  ),
                  IconButton(
                    icon: Icon(Icons.video_library),
                    onPressed: (){
                      videoGen('video', ImageSource.gallery);
                    },
                    color: Colors.blueAccent,
                  ),
                  IconButton(
                    icon: Icon(Icons.title),
                    onPressed: (){
                      textGenButton('text', context);
                    },
                    color: Colors.blueAccent,
                  )
                ],
              ),
            ),
          ),
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

  //add new Text
  void textGenButton(String mdGenType, BuildContext context, [String setValue = '']){
    bool inText = false;
    int indexNext = bloc.index + 1;
    //check if we are in a text field && check if the selector cursor is at the end or not
    if(
    mediaGens[bloc.index].focusing == true ||
        mediaGens[bloc.index].type == 'text' ||
        mediaGens[indexNext].type == 'text'
    ){
      inText = true;
    }
    if(setValue != '') inText = false;

    if(inText == false){
      removeEmptyTextField();
      String id = Uuid().v1();
      MediaGenerator mdGenText = MediaGenerator(id: id, type: 'text', context: context);
      Widget textField = mdGenText.mnInput(setValue);
      mdGenText.stopGapperBlinkers = (){
        stopGapperBlinkers();
      };
      mdGenText.setIndex = (){
        setIndex();
      };
      setState((){
        bloc.index = bloc.index + 1;
        mediaGens.insert(bloc.index, mdGenText);
        mediaList.insert(bloc.index, textField);
      });
    }
  }

  //add new Text
  void textGen(String mdGenType, BuildContext context, [String setValue = '']){
    removeEmptyTextField();
    String id = Uuid().v1();
    MediaGenerator mdGenText = MediaGenerator(id: id, type: 'text', context: context);
    Widget textField = mdGenText.mnInput(setValue);
    mdGenText.stopGapperBlinkers = (){
      stopGapperBlinkers();
    };
    mdGenText.setIndex = (){
      setIndex();
    };
    setState((){
      bloc.index = bloc.index + 1;
      mediaGens.insert(bloc.index, mdGenText);
      mediaList.insert(bloc.index, textField);
    });
  }



  //add new image (camera and gallery)
  void imageGen(String mdGenType, ImageSource src){
    removeEmptyTextField();
    bool inText = false;
    String afterValue = '';
    //check if we are in a text field && check if the selector cursor is at the end or not
    if(mediaGens[bloc.index].focusing == true && mediaGens[bloc.index].type == 'text' && mediaGens[bloc.index].mnValueAfter() != ''){
      inText = true;
      afterValue = mediaGens[bloc.index].mnValueAfter();
      mediaGens[bloc.index].setMnValue(mediaGens[bloc.index].mnValueBefore());
    }

    String id = Uuid().v1();
    MediaGenerator mdGen = MediaGenerator(id: id, type: mdGenType, context: context);
    Widget photo = mdGen.getPhoto(context, src);
    mdGen.delete = (){
      setState(() {
        mediaList.remove(photo);
        mediaGens.remove(mdGen);
        setIndex();
      });
    };
    mdGen.stopGapperBlinkers = (){
      stopGapperBlinkers();
    };
    mdGen.setIndex = (){
      setIndex();
    };
    setState((){
      bloc.index = bloc.index + 1;
      mediaGens.insert(bloc.index, mdGen);
      mediaList.insert(bloc.index, photo);
    });
    // setIndex();
    if(inText == true) {
      textGen('text', context, afterValue);
      Future.delayed(Duration(milliseconds: 100), selectPrevious);
    }
    stopGapperBlinkers();
  }


  //add new video (camera and gallery)
  void videoGen(String mdGenType, ImageSource src){
    removeEmptyTextField();
    bool inText = false;
    String afterValue = '';
    //check if we are in a text field && check if the selector cursor is at the end or not
    if(mediaGens[bloc.index].focusing == true && mediaGens[bloc.index].type == 'text' && mediaGens[bloc.index].mnValueAfter() != ''){
      inText = true;
      afterValue = mediaGens[bloc.index].mnValueAfter();
      mediaGens[bloc.index].setMnValue(mediaGens[bloc.index].mnValueBefore());
    }

    String id = Uuid().v1();
    MediaGenerator mdGen = MediaGenerator(id: id, type: mdGenType, context: context);
    Widget video = mdGen.getVideo(context, src);
    mdGen.delete = (){
      setState(() {
        mediaList.remove(video);
        mediaGens.remove(mdGen);
        setIndex();
      });
    };
    mdGen.stopGapperBlinkers = (){
      stopGapperBlinkers();
    };
    mdGen.setIndex = (){
      setIndex();
    };
    setState((){
      bloc.index = bloc.index + 1;
      mediaGens.insert(bloc.index, mdGen);
      mediaList.insert(bloc.index, video);
    });
    // setIndex();
    if(inText == true) {
      textGen('text', context, afterValue);
      Future.delayed(Duration(milliseconds: 100), selectPrevious);
    }
    stopGapperBlinkers();
  }



  //add new text field at the bottom invisible container
  void invisibleBoxTextGenBottom(){
    MediaGenerator lastOne = mediaGens.last;
    if(lastOne.type != 'text'){
      String id = Uuid().v1();
      MediaGenerator mdGenText = MediaGenerator(id: id, type: 'text', context: context);
      Widget textField = mdGenText.mnInput();
      mdGenText.stopGapperBlinkers = (){
        stopGapperBlinkers();
      };
      mdGenText.setIndex = (){
        setIndex();
      };
      setState((){
        mediaList.add(textField);
        mediaGens.add(mdGenText);
      });
    }
  }




  void removeEmptyTextField(){
    String currentSelected = bloc.selected;
    String previousId = '';
    if(mediaGens.length > 1){ //first text field won't be deleted skipping 0 index
      for(int i = 0; i < mediaGens.length; i++){
        MediaGenerator mg = mediaGens[i];
        if(mg.type == 'text' && i != 0  && (mg.mnValue() == '')){
          if(mg.id == currentSelected) { //because current index is about to be removed so select previous one
            bloc.selected = previousId;
          }
          setState(() {
            mediaList.remove(mediaList[i]);
            mediaGens.remove(mg);
          });
        }
        ////
        previousId = mg.id;
      }
      setIndex();
    }
  }


  void baseGestureDetector(){
    //remove focus from text fields
    FocusManager.instance.primaryFocus?.unfocus();
    bloc.selected = mediaGens.last.id;
    bloc.index = mediaGens.length - 1;
    stopGapperBlinkers();
  }


  void stopGapperBlinkers(){
    for(MediaGenerator mg in mediaGens){
      mg.stopGapperBlinking();
      if(mg.id == bloc.selected){
        mg.startBlinking();
      }
    }
  }

  void setIndex(){
    int i = 0;
    bool selectedFound = false;
    for(MediaGenerator mg in mediaGens){
      if(mg.id == bloc.selected){
        bloc.index = i;
        selectedFound = true;
      }
      i++;
    }
    if(selectedFound == false){
      baseGestureDetector();
    }
  }


  void selectPrevious(){
    int i = bloc.index - 1;
    MediaGenerator mg = mediaGens[i];
    bloc.selected = mg.id;
    bloc.index = i;
    stopGapperBlinkers();
  }


  //store names instead of file path
  String buildJsonString(){
    String jsonOutput = '[';
    int index = 0;
    for(MediaGenerator mg in mediaGens){
      var singleEntry = {};
      singleEntry['index'] = index.toString();
      singleEntry['type'] = mg.type;
      if(mg.type == 'text'){
        singleEntry['value'] = mg.mnValue();
      }else{
        singleEntry['value'] = mg.fileName;
      }
      String singleEntryJson = json.encode(singleEntry);
      jsonOutput = (index != 0) ? jsonOutput + ',' : jsonOutput;
      jsonOutput = jsonOutput + singleEntryJson;
      index++;
    }
    jsonOutput = jsonOutput + ']';
    // debugPrint(jsonOutput);
    return jsonOutput;
  }

  bool checkJsonEmpty(){
    String jsonOutput = '';
    for(MediaGenerator mg in mediaGens){
      if(mg.type == 'text'){
        jsonOutput += mg.mnValue();
      }else{
        jsonOutput += mg.fileName;
      }
    }
    if(jsonOutput == ''){
      return true;
    }else{
      return false;
    }
  }


  String buildInfoJson(){
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime dateTimeTimeStamp = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var info = {};
    info['title'] = titleController.text;
    info['date'] = dateTimeTimeStamp.toString();
    info['type'] = '0';
    String infoJson = json.encode(info);
    return infoJson;
  }


  void setTitleText(String loadedInfo){
    var jsonDecoded = jsonDecode(loadedInfo);
    titleController.text = jsonDecoded['title'];
  }

  void loadMediaGeneratorFromJson(String jsonString){
    var jsonDecoded = jsonDecode(jsonString);
    setState(() {
      for(Map<String, dynamic> jd in jsonDecoded){
        if(jd['type'] == 'text'){
          loadText('text', jd['value']);
        }else if(jd['type'] == 'image'){
          loadImage(jd['value']);
        }else if(jd['type'] == 'video'){
          loadVideo(jd['value']);
        }
      }
    });
    Future.delayed(Duration(milliseconds: 500), baseGestureDetector);
  }

  void loadImage(String value){
    String id = Uuid().v1();
    MediaGenerator mdGen = MediaGenerator(id: id, type: 'image', context: context);
    mdGen.folder = bloc.name;
    mdGen.fileName = value;
    Widget photo = mdGen.loadPhotoFromDevice(context);
    mdGen.delete = (){
      setState(() {
        mediaList.remove(photo);
        mediaGens.remove(mdGen);
        setIndex();
      });
    };
    mdGen.stopGapperBlinkers = (){
      stopGapperBlinkers();
    };
    mdGen.setIndex = (){
      setIndex();
    };
    setState((){
      mediaGens.add(mdGen);
      mediaList.add(photo);
    });
  }

  void loadVideo(value){
    String id = Uuid().v1();
    MediaGenerator mdGen = MediaGenerator(id: id, type: 'video', context: context);
    mdGen.folder = bloc.name;
    mdGen.fileName = value;
    Widget video = mdGen.loadVideoFromDevice(context);
    mdGen.delete = (){
      setState(() {
        mediaList.remove(video);
        mediaGens.remove(mdGen);
        setIndex();
      });
    };
    mdGen.stopGapperBlinkers = (){
      stopGapperBlinkers();
    };
    mdGen.setIndex = (){
      setIndex();
    };
    setState((){
      mediaGens.add(mdGen);
      mediaList.add(video);
    });
  }

  void loadText(String mdGenType, [String setValue = '']){
    String id = Uuid().v1();
    MediaGenerator mdGenText = MediaGenerator(id: id, type: 'text', context: context);
    Widget textField = mdGenText.mnInput(setValue);
    mdGenText.stopGapperBlinkers = (){
      stopGapperBlinkers();
    };
    mdGenText.setIndex = (){
      setIndex();
    };
    setState((){
      mediaGens.add(mdGenText);
      mediaList.add(textField);
    });
  }

  bool workingBackground(){
    bool working = false;
    for(MediaGenerator mg in mediaGens){
      if(mg.working == true){
        working = true;
        break;
      }
    }
    return working;
  }

  Future<bool> save() async{
    if(titleController.text == '' && checkJsonEmpty() == true){
      return true;
    }
    SaveData saveData = SaveData(noteName: noteName, jsonString: buildJsonString(), infoJson: buildInfoJson());
    saveData.save();
    return saveData.checkJsonFormat();
  }

  alertWorking(){
    return Alert(
      buttons: [
        DialogButton(child: Text('OK'), onPressed: () => Navigator.pop(context)),
      ],
      context: context,
      title: 'Oops!',
      desc: 'Please wait while the background process finishes.',
    ).show();
  }

}

