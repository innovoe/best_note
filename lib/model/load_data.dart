import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LoadData{
  String noteName;
  LoadData(this.noteName);

  Future<String> loadJsonFromName() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = appDir.path + '/bestNoteSaves/$noteName/bnData.json';
    File bnData = File(filePath);
    if(await bnData.exists()){
      String jsonString = await bnData.readAsString();
      return jsonString;
    }else{
      return '';
    }
  }

  Future<String> loadInfoFromName() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = appDir.path + '/bestNoteSaves/$noteName/info.json';
    File bnData = File(filePath);
    if(await bnData.exists()){
      String jsonString = await bnData.readAsString();
      return jsonString;
    }else{
      return '';
    }
  }

  Future<void> deleteNote() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    String dirPath = appDir.path + '/bestNoteSaves/$noteName';
    Directory directory = Directory(dirPath);
    directory.deleteSync(recursive: true);
  }


}