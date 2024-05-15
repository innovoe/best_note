import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class MnvPlayer extends StatefulWidget {
  final String videoUrl;
  MnvPlayer({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _MnvPlayerState createState() => _MnvPlayerState();
}

class _MnvPlayerState extends State<MnvPlayer>{

  late VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final File _file = File(widget.videoUrl);
    _controller = VideoPlayerController.file(_file)
      ..initialize().then((_) => setState((){}))
      ..setLooping(true);
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      onVisibilityChanged: (VisibilityInfo info) {
        if(info.visibleFraction == 0){
          _controller.pause();
        }
      },
      key: Key('Video Player'),
      child: GestureDetector(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            children: [
              VideoPlayer(_controller),
              Positioned(
                child: Icon(Icons.play_circle, color: Colors.black87,),
                top: 5,
                left: 5,
              )
            ],
          ),
        )
            : Container(),
        onTap: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        // onLongPress: (){
        //   setState(() {
        //     _controller.play();
        //   });
        // },
        // onLongPressUp: (){
        //   setState(() {
        //     _controller.pause();
        //   });
        // },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // routeObserver.subscribe(this, ModalRoute.of(context)!);
  }



  @override
  void dispose() {
    // routeObserver.unsubscribe(this); //Don't forget to unsubscribe it!!!!!!
    super.dispose();
    _controller.dispose();
  }
}
