import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

class HomePageNoteList{
  List<String> names = [];

  final _homePageNoteListStreamController = BehaviorSubject<List<String>>();

  Stream<List<String>> get homePageNoteStream => _homePageNoteListStreamController.stream;
  StreamSink<List<String>> get homePageNoteSink => _homePageNoteListStreamController.sink;

  // HomePageNoteList(){
  //   getNoteNames().then((_) => _homePageNoteListStreamController.add(names));
  // }

  Future<void> getNoteNames() async{
    names.clear();
    Directory appDir = await getApplicationDocumentsDirectory();
    Directory filePath = Directory(appDir.path.toString() + '/bestNoteSaves/');
    if(await filePath.exists() == false){
      await filePath.create(recursive: false);
    }
    Stream<FileSystemEntity> dirList = filePath.list(
        recursive: false,
        followLinks: false
    );
    await dirList.listen((dirName) async{
      String name = dirName.toString().split('/').last.replaceAll("'", "");
      names.add(name);
    }).asFuture();//it does not wait without declaring as future.
    names = names.toSet().toList();
    names.sort((b, a) => a.compareTo(b));
    _homePageNoteListStreamController.sink.add(names);
  }
}

HomePageNoteList homePageNoteList = HomePageNoteList();