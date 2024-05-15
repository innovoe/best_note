import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class ImageGenerator{

  late final String imagePath;

  Future<Widget> takePhoto() async{
    final _picker = ImagePicker();
    final XFile? _image = await _picker.pickImage(source: ImageSource.camera);
    imagePath = _image!.path;
    File _file = File(imagePath);
    return Image.file(_file);
  }

}
