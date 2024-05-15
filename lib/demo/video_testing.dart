import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoTesting extends StatefulWidget {
  const VideoTesting({Key? key}) : super(key: key);

  @override
  _VideoTestingState createState() => _VideoTestingState();
}

class _VideoTestingState extends State<VideoTesting> {

  late VideoPlayerController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.network('https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4')
    ..initialize().then((_) => setState((){}));
  }

  @override
  Widget build(BuildContext context) {
    print(_controller.value.isInitialized);
    return Scaffold(
      appBar: AppBar(title: Text('video testing'),),
      body: GestureDetector(
        child: Container(
          child: _controller.value.isInitialized
          ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
          : Container(),
        ),
        // onTap: () {
        //   setState(() {
        //     _controller.value.isPlaying
        //         ? _controller.pause()
        //         : _controller.play();
        //   });
        // },
        onLongPress: (){
          setState(() {
            _controller.play();
          });
        },
        onLongPressUp: (){
          setState(() {
            _controller.pause();
          });
        },
      ),
    );
  }
}

