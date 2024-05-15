import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:best_note/model/mn_video_player.dart';

class ImageAndCamera extends StatefulWidget {
  const ImageAndCamera({Key? key}) : super(key: key);

  @override
  _ImageAndCameraState createState() => _ImageAndCameraState();
}

class _ImageAndCameraState extends State<ImageAndCamera> {

  Future<String> imageSelect(bool takeImage, ImageSource imageSrc) async{
    if(takeImage){
      final _picker = ImagePicker();
      final XFile? _image = await _picker.pickImage(source: imageSrc);
      return _image!.path;
    }
    else{
      return Future.error('no image taken yet', StackTrace.fromString('stackTraceString'));
    }

  }

  Future<String> videoSelect(bool takeVideo, ImageSource videoSrc) async{
    if(takeVideo){
      final _picker = ImagePicker();
      final XFile? _video = await _picker.pickVideo(source: videoSrc);
      return _video!.path;
    }else{
      return Future.error('no video taken yet', StackTrace.fromString('stackTraceString'));
    }

  }

  bool takeImage = false;
  ImageSource imageSrc = ImageSource.camera;

  bool takeVideo = false;
  ImageSource videoSrc = ImageSource.gallery;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Image Picker Test'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
              future: imageSelect(takeImage, imageSrc),
              builder: (context, snapshot){
                if(snapshot.hasError){
                  // return Text(snapshot.error.toString());
                  return Image.network('https://t4.ftcdn.net/jpg/01/92/63/21/360_F_192632183_VipMtXboxtK9R9X4Hq2j8lQoRLHxb1ew.jpg');
                }
                else if(snapshot.hasData){
                  File _file = File(snapshot.data.toString());
                  takeImage = false;
                  return Image.file(_file);
                }
                else{
                  return Image.network('https://t4.ftcdn.net/jpg/01/92/63/21/360_F_192632183_VipMtXboxtK9R9X4Hq2j8lQoRLHxb1ew.jpg');
                }
              },
            ),
            FutureBuilder(
              future: videoSelect(takeVideo, videoSrc),
              builder: (context, snapshot){
                if(snapshot.hasError){
                  return Text(snapshot.error.toString());
                  // return Image.network('https://t4.ftcdn.net/jpg/01/92/63/21/360_F_192632183_VipMtXboxtK9R9X4Hq2j8lQoRLHxb1ew.jpg');
                }
                else if(snapshot.hasData){
                  takeVideo = false;
                  return MnvPlayer(videoUrl: snapshot.data.toString());
                }
                else{
                  return Image.network('https://t4.ftcdn.net/jpg/01/92/63/21/360_F_192632183_VipMtXboxtK9R9X4Hq2j8lQoRLHxb1ew.jpg');
                }
              },
            )
          ],
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
                setState(() {
                  takeImage = true;
                  imageSrc = ImageSource.camera;
                });
              },
              color: Colors.blueAccent,
            ),
            IconButton(
              icon: Icon(Icons.add_photo_alternate_sharp),
              onPressed: (){
                setState(() {
                  takeImage = true;
                  imageSrc = ImageSource.gallery;
                });
              },
              color: Colors.blueAccent,
            ),
            IconButton(
              icon: Icon(Icons.alarm_on_outlined),
              onPressed: (){
                setState(() {
                  takeVideo = true;
                  videoSrc = ImageSource.camera;
                });
              },
              color: Colors.blueAccent,
            ),
            IconButton(
              icon: Icon(Icons.three_g_mobiledata),
              onPressed: (){
                setState(() {
                  takeVideo = true;
                  videoSrc = ImageSource.gallery;
                });
              },
              color: Colors.blueAccent,
            ),
          ],
        ),
      ),
    );
  }
}
