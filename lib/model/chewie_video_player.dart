import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class ChewieVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const ChewieVideoPlayer({Key? key, required this.videoUrl}) : super(key: key);
  @override
  State<ChewieVideoPlayer> createState() => ChewieVideoPlayerState();
}

class ChewieVideoPlayerState extends State<ChewieVideoPlayer> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final File videoFile = File(widget.videoUrl);
    videoPlayerController = VideoPlayerController.file(videoFile);
    videoPlayerController.initialize().then((_) => setState((){}));
  }


  @override
  Widget build(BuildContext context) {
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      looping: true,
    );
    final playerWidget = Chewie(
      controller: chewieController,
    );
    return playerWidget;
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }
}