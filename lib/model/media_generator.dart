import 'package:best_note/model/bloc.dart';
import 'package:best_note/model/fullscreen_path_args.dart';
import 'package:best_note/model/gapper.dart';
import 'package:best_note/model/video_compressor.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:best_note/model/mn_video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class MediaGenerator{
  final BuildContext context;
  late final String id; //unique id for every instance
  late final String type; //text, image, video, gapper
  final _mnTextController = TextEditingController();//for text
  bool ignore = false; //not decided yet
  late VoidCallback delete; //delete instance from list
  late VoidCallback stopGapperBlinkers; //blink only the selected gapper(value is in the bloc)
  late VoidCallback setIndex; //loop and set index
  late int index;
  var focusNode = FocusNode(); //focus controller for text fields
  bool focusing = false;
  GlobalKey<GapperState> gapKey = GlobalKey();
  String fileName = '';
  String folder = '';
  bool working = false;

  MediaGenerator({required this.id, required this.type, required this.context});

  void dispose(){
    _mnTextController.dispose();
    if(gapKey.currentState != null) gapKey.currentState!.dispose();
    delete();
  }


  Widget mnInput([String setValue = '']){
    focusNode.requestFocus();
    if(setValue != ''){
      _mnTextController.text = setValue;
    }
    focusNode.addListener((){
      if(focusNode.hasFocus){
        focusing = true;
        // stopGapperBlinkers();
      }else{
        focusing = false;
      }
    });
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
        focusNode: focusNode,
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

  //image

  String imagePath = '';
  String compressedImagePath = '';


  Future<String> _takePhoto(ImageSource photoSource) async{
    final _picker = ImagePicker();
    final XFile? _image = await _picker.pickImage(source: photoSource);
    String largeFilePath = _image!.path;
    File compressedFile = await FlutterNativeImage.compressImage(
      largeFilePath,
      quality: 25
    );

    Directory toBeDeleted = Directory(largeFilePath);
    toBeDeleted.deleteSync(recursive: true);
    Directory appDir = await getTemporaryDirectory();
    Uuid uniqueName = Uuid();
    String uniqueJpg = uniqueName.v1();
    String tempFilePath = appDir.path + '/' + uniqueJpg + '.jpg';
    await compressedFile.copy(tempFilePath);
    compressedImagePath = tempFilePath;
    fileName = uniqueJpg + '.jpg';
    return tempFilePath;
  }

  Widget getPhoto(BuildContext context, ImageSource photoSource){
    bloc.selected = id;
    return Wrap(
      children: [
        FutureBuilder(
          future: _takePhoto(photoSource),
          builder: (context, AsyncSnapshot snapshot){
            if(snapshot.hasError){
              working = false;
              ignore = true;
              return GestureDetector(
                onLongPress: dispose,
                onDoubleTap: dispose,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  width: 80,
                  height: 150,
                  padding: EdgeInsets.all(10),
                  color: Colors.grey[200],
                  child: Text('Couldn\'t process Photo'),
                ),
              );
            }else if(snapshot.hasData && snapshot.data == compressedImagePath){
              working = false;
              //snapshot.hasData triggered true multiple times and giving previous data while list.insert
              //so making sure it's the right data  (snapshot.data == compressedImagePath)
              // debugPrint(snapshot.data);
              String compressedPath = snapshot.data.toString();
              return GestureDetector(
                onDoubleTap: (){
                  Navigator.pushNamed(context, '/fullscreenOpener', arguments: FullscreenPathArgs('Image', compressedPath));
                },
                child: imageContainer(compressedPath),
              );
            }else {
              working = true;
              return GestureDetector(
                onLongPress: dispose,
                onDoubleTap: dispose,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      width: 80,
                      height: 150,
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                      color: Colors.grey[200],
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 5,
                      child: GestureDetector(
                          onLongPress: dispose,
                          child: CircleAvatar(radius: 13, backgroundColor: Colors.white54 ,child: Icon(Icons.close))
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        gapper(),
      ],
    );
  }


  Widget imageContainer(String compressedImage){
    File compressedImageFile = File(compressedImage);
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
          height: 150,
          child: Image.file(compressedImageFile),
        ),
        Positioned(
          top: 10,
          right: 5,
          child: GestureDetector(
            onLongPress: dispose,
            child: CircleAvatar(radius: 13, backgroundColor: Colors.white54 ,child: Icon(Icons.close))
          ),
        ),
      ],
    );
  }


  Widget loadPhotoFromDevice(BuildContext context){
    return Wrap(
      children: [
        FutureBuilder(
          future: _loadMedia(),
          builder: (context, AsyncSnapshot snapshot){
            if(snapshot.hasError){
              working = false;
              ignore = true;
              return GestureDetector(
                onLongPress: dispose,
                onDoubleTap: dispose,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  width: 80,
                  height: 150,
                  padding: EdgeInsets.all(10),
                  color: Colors.grey[200],
                  child: Text('Couldn\'t process Photo'),
                ),
              );
            }else if(snapshot.hasData && snapshot.data == compressedImagePath){
              working = false;
              //snapshot.hasData triggered true multiple times and giving previous data while list.insert
              //so making sure it's the right data  (snapshot.data == compressedImagePath)
              // debugPrint(snapshot.data);
              String compressedPath = snapshot.data.toString();
              return GestureDetector(
                onDoubleTap: (){
                  Navigator.pushNamed(context, '/fullscreenOpener', arguments: FullscreenPathArgs('Image', compressedPath));
                },
                child: imageContainer(compressedPath),
              );
            }else {
              working = true;
              return GestureDetector(
                onLongPress: dispose,
                onDoubleTap: dispose,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      width: 80,
                      height: 150,
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                      color: Colors.grey[200],
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 5,
                      child: GestureDetector(
                          onLongPress: dispose,
                          child: CircleAvatar(radius: 13, backgroundColor: Colors.white54 ,child: Icon(Icons.close))
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        gapper(),
      ],
    );
  }














  //video
  String videoPath = '';
  // Stream<double> compressProgress = 0.0 as Stream<double>;
  //
  // Widget compressProgressBuilder(){
  //   return StreamBuilder(
  //     stream: compressProgress,
  //     builder: (context, snapshot){
  //       if(snapshot.hasData){
  //         return LinearProgressIndicator(value: snapshot.data as double);
  //       }else{
  //         return LinearProgressIndicator();
  //       }
  //     },
  //   );
  // }

  Future<String> _takeVideo(ImageSource videoSource) async{
    try{
      final _picker = ImagePicker();
      final XFile? _image = await _picker.pickVideo(source: videoSource);
      if(_image == null) return Future.error('_image Null');
      Directory appDir = await getTemporaryDirectory();
      Uuid uniqueName = Uuid();
      String uniqueVideoFileName = uniqueName.v1();
      String tempFilePath = appDir.path + '/' + uniqueVideoFileName + '.mp4';
      videoPath = tempFilePath;
      fileName = uniqueVideoFileName + '.mp4';
      VideoCompressor videoCompressor = VideoCompressor(path: _image.path, destinationPath: videoPath);
      // compressProgress = videoCompressor.videoCompressUpdate;
      bool success = await videoCompressor.compress();
      if(success == true){
        return videoPath;
      }else{
        return Future.error('video compress failed');
      }

    }catch(e){
      throw Exception('_takeVideo error $e');
    }
  }

  Widget getVideo(BuildContext context, ImageSource videoSource){
    bloc.selected = id;
    return Wrap(
      children: [
        FutureBuilder(
          future: _takeVideo(videoSource),
          builder: (context, snapshot){
            if(snapshot.hasError){
              working = false;
              ignore = true;
              print('----------------------------------------------------------------------- ${snapshot.error.toString()}');
              return GestureDetector(
                onLongPress: dispose,
                onDoubleTap: dispose,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  width: 80,
                  height: 150,
                  padding: EdgeInsets.all(10),
                  color: Colors.grey[200],
                  child: Text('couldn\'t process video'),
                ),
              );
            }else if(snapshot.hasData && (snapshot.data.toString() == videoPath)){
              working = false;
              return GestureDetector(
                onDoubleTap: (){
                  Navigator.pushNamed(context, '/fullscreenOpener', arguments: FullscreenPathArgs('Video', videoPath));
                },
                child: videoContainer(videoPath),
              );
            }else{
              working = true;
              return GestureDetector(
                onLongPress: dispose,
                onDoubleTap: dispose,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      width: 80,
                      height: 150,
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                      color: Colors.grey[200],
                      child: Stack(
                        children: const [
                          // compressProgressBuilder(),
                          CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          Positioned(
                            bottom: 2,
                            child: Text('Processing')
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 5,
                      child: GestureDetector(
                          onLongPress: dispose,
                          child: CircleAvatar(radius: 13, backgroundColor: Colors.white54 ,child: Icon(Icons.close))
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        gapper()
      ],
    );
  }


  Widget loadVideoFromDevice(BuildContext context){
    bloc.selected = id;
    return Wrap(
      children: [
        FutureBuilder(
          future: _loadMedia(),
          builder: (context, snapshot){
            if(snapshot.hasError){
              working = false;
              ignore = true;
              return GestureDetector(
                onLongPress: dispose,
                onDoubleTap: dispose,
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                  width: 80,
                  height: 150,
                  padding: EdgeInsets.all(10),
                  color: Colors.grey[200],
                  child: Text('couldn\'t process video'),
                ),
              );
            }else if(snapshot.hasData && (snapshot.data.toString() == videoPath)){
              working = false;
              return GestureDetector(
                onDoubleTap: (){
                  Navigator.pushNamed(context, '/fullscreenOpener', arguments: FullscreenPathArgs('Video', videoPath));
                },
                child: videoContainer(videoPath),
              );
            }else{
              working = true;
              return GestureDetector(
                onLongPress: dispose,
                onDoubleTap: dispose,
                child: Stack(
                  children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      width: 80,
                      height: 150,
                      padding: EdgeInsets.fromLTRB(20, 40, 20, 40),
                      color: Colors.grey[200],
                      child: Stack(
                        children: const [
                          CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          Positioned(
                              bottom: 2,
                              child: Text('Processing')
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 5,
                      child: GestureDetector(
                          onLongPress: dispose,
                          child: CircleAvatar(radius: 13, backgroundColor: Colors.white54 ,child: Icon(Icons.close))
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
        gapper()
      ],
    );
  }


  Widget videoContainer(String videoPath){
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
          height: 150,
          child: MnvPlayer(videoUrl: videoPath),
        ),
        Positioned(
          top: 10,
          right: 5,
          child: GestureDetector(
              onLongPress: dispose,
              child: CircleAvatar(radius: 13, backgroundColor: Colors.white54 ,child: Icon(Icons.close))
          ),
        ),
      ],
    );
  }







  //while loading from json string
  //folder and fileName variable must be set before calling this
  Future<String> _loadMedia() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    videoPath = appDir.path + '/bestNoteSaves/' + folder + '/' + fileName;
    compressedImagePath = appDir.path + '/bestNoteSaves/' + folder + '/' + fileName;
    return videoPath;
  }




  //Gapper
  Widget gapper(){
    Widget gap = Gapper(key: gapKey);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: (){
        bloc.selected = id;
        stopGapperBlinkers();
        setIndex();
        gapKey.currentState!.blink();
      },
      child: gap,
    );
  }

  void stopGapperBlinking(){
    if(type != 'text'){
      if(gapKey.currentState != null) gapKey.currentState!.stop();
    }
  }

  void startBlinking(){
    if(type != 'text'){
      if(gapKey.currentState != null) gapKey.currentState!.blink();
    }
  }


}


