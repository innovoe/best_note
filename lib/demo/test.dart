import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:best_note/model/media_generator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:best_note/model/bloc.dart';
import 'package:uuid/uuid.dart';

class NoteWithImageVideo extends StatefulWidget {
  const NoteWithImageVideo({Key? key}) : super(key: key);

  @override
  _NoteWithImageVideoState createState() => _NoteWithImageVideoState();
}

class _NoteWithImageVideoState extends State<NoteWithImageVideo> {
  //required lists
  List<Widget> mediaList = [];
  List<MediaGenerator> mediaGens = [];
  String debuggerString = '';
  String savingPrivateJson = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> wrapList = mediaList;
    int index = bloc.index;
    return GestureDetector(
      onTap: () => baseGestureDetector(),
      child: Scaffold(
        body: Scaffold(
          appBar: AppBar(
            title: Text(index.toString()),
            actions: [
              ElevatedButton(
                child: Text('Index'),
                onPressed: (){
                  setState(() {
                    debuggerString = bloc.selected;
                    index = bloc.index;
                    selectPrevious();
                    buildJsonString();
                  });
                },
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(debuggerString),
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
                    textGen('text', context);
                  },
                  color: Colors.blueAccent,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }


  //add new Text
  void textGen(String mdGenType, BuildContext context, [String setValue = '']){
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

  //add new video both camera and gallery
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


  // void videoGen(String mdGenType, ImageSource src){
  //   removeEmptyTextField();
  //   String id = Uuid().v1();
  //   MediaGenerator mdGen = MediaGenerator(id: id, type: mdGenType, context: context);
  //   Widget video = mdGen.getVideo(context, src);
  //   mdGen.delete = (){
  //     setState(() {
  //       mediaList.remove(video);
  //       mediaGens.remove(mdGen);
  //       setIndex();
  //     });
  //   };
  //   mdGen.stopGapperBlinkers = (){
  //     stopGapperBlinkers();
  //   };
  //   mdGen.setIndex = (){
  //     setIndex();
  //   };
  //   setState((){
  //     int blocIndexPlus = bloc.index + 1;
  //     mediaGens.insert(blocIndexPlus,mdGen);
  //     mediaList.insert(blocIndexPlus,video);
  //     bloc.index = blocIndexPlus;
  //   });
  //   stopGapperBlinkers();
  // }

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



  void buildJsonString(){
    String jsonOutput = '[';
    int index = 0;
    for(MediaGenerator mg in mediaGens){
      var singleEntry = {};
      singleEntry['index'] = index.toString();
      singleEntry['type'] = mg.type;
      if(mg.type == 'text'){
        singleEntry['value'] = mg.mnValue();
      }else if(mg.type == 'image'){
        singleEntry['value'] = mg.compressedImagePath;
      }else if(mg.type == 'video'){
        singleEntry['value'] = mg.videoPath;
      }else{
        singleEntry['value'] = 'problem';
      }
      String singleEntryJson = json.encode(singleEntry);
      jsonOutput = (index != 0) ? jsonOutput + ',' : jsonOutput;
      jsonOutput = jsonOutput + singleEntryJson;
      index++;
    }
    jsonOutput = jsonOutput + ']';
    debugPrint(jsonOutput);
  }


}

