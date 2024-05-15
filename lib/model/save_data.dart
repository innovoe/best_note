import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SaveData{
  bool creatingNew = false;
  String noteName;
  String jsonString;
  String infoJson;
  SaveData({required this.noteName, required this.jsonString, required this.infoJson});
  List names = [];

  void save() async{
    await createFolderAndSaveJson();
    await saveInfo();
    await copyMediaFilesFromCache();
  }

  bool checkJsonFormat(){
    bool jsonPass = false;
    try {
      json.decode(jsonString);
      jsonPass = true;
    }catch(e){
      jsonPass = false;
      throw Exception('Json String problem. Error: $e');
    }
    return jsonPass;
  }

  Future<void> createFolderAndSaveJson() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = appDir.path + '/bestNoteSaves/$noteName/bnData.json';
    File bnData = File(filePath);
    await bnData.create(recursive: true);
    await bnData.writeAsString(jsonString);
  }

  Future<void> saveInfo() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = appDir.path + '/bestNoteSaves/$noteName/info.json';
    File bnData = File(filePath);
    if(await bnData.exists()){
      var updateJson = {};
      String bnInfoString = await bnData.readAsString();
      var jdRead= jsonDecode(bnInfoString);
      String originalDate = jdRead['date'];
      String type = jdRead['type'];
      var jdGet = jsonDecode(infoJson);
      String title = jdGet['title'];
      updateJson['title'] = title;
      updateJson['date'] = originalDate;
      updateJson['type'] = type;
      String updateJsonString = json.encode(updateJson);
      bnData.writeAsString(updateJsonString);
    }else{
      await bnData.create(recursive: true);
      await bnData.writeAsString(infoJson);
    }
  }

  Future<void> copyMediaFilesFromCache() async{
    Directory tempDir = await getTemporaryDirectory();
    Directory appDir = await getApplicationDocumentsDirectory();
    var jsonDecoded = jsonDecode(jsonString);
    for(var jd in jsonDecoded){
      if(jd['type'] != 'text'){
        String tempPath = tempDir.path + '/' + jd['value'].toString();
        String appPath = appDir.path + '/bestNoteSaves/$noteName/' + jd['value'].toString();
        File tempFile = File(tempPath);
        File appFile = File(appPath);
        if(await appFile.exists() == false){
          await tempFile.copy(appPath);
        }
      }
    }
  }

  Future<String> loadJsonFromName() async{
    Directory appDir = await getApplicationDocumentsDirectory();
    String filePath = appDir.path + '/bestNoteSaves/$noteName/bnData.json';
    File bnData = File(filePath);
    if(await bnData.exists()){
      String out = await bnData.readAsString();
      return out;
    }else{
      return '';
    }
  }

}
