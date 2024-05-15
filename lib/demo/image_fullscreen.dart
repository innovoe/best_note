import 'dart:io';

import 'package:flutter/material.dart';

class ImageFullScreen extends StatelessWidget {
  const ImageFullScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imagePath = '';
    // final Object? args = ModalRoute.of(context)!.settings.arguments;
    // imagePath = args!['imagePath'];

    // File _file = File(imagePath);
    return Scaffold(
      appBar: AppBar(title: Text('Image Viewer'),),
      // body: Image.file(_file),
    );
  }
}
