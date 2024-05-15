import 'dart:io';
import 'package:best_note/model/fullscreen_path_args.dart';
// import 'package:best_note/model/mn_video_player.dart';
import 'package:flutter/material.dart';
import 'package:best_note/model/chewie_video_player.dart';

class FullscreenOpener extends StatelessWidget{
  const FullscreenOpener({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)!.settings.arguments as FullscreenPathArgs;
    Widget theChild;
    if(arg.type == 'Image'){
      File _file = File(arg.path);
      theChild = Image.file(_file);
    }else if(arg.type == 'Video'){
      theChild = ChewieVideoPlayer(videoUrl: arg.path);
    }else{
      theChild = Text('Couldn\'t Open the Media');
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black87, //change your color here
        ),
        elevation: 0,
        backgroundColor: Colors.white70,
      ),
      body: theChild,
    );
  }
}
