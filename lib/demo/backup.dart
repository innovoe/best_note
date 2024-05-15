import 'package:flutter/material.dart';
import 'package:best_note/model/google_user.dart';
import 'package:provider/provider.dart';

class Backup extends StatefulWidget {
  const Backup({Key? key}) : super(key: key);

  @override
  _BackupState createState() => _BackupState();
}

class _BackupState extends State<Backup> {
  List<Widget> backupChildren = [];
  double progressValue = 0.0;
  String status = '';
  String mode = 'searchViewList';

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<GoogleUser>(context);
    List<Widget> showList;
    List<Widget> searchViewList = [
      FutureBuilder(
          future: provider.driveSearchFile(downloadAndRestore, createNewBackup),
          builder: (context, snapshot) {
            if(snapshot.hasError){
              return Text(snapshot.error.toString());
            }else if(snapshot.hasData && snapshot.connectionState == ConnectionState.done){
              return snapshot.data as Widget;
            }else{
              return Column(
                children: const[
                  LinearProgressIndicator(),
                  SizedBox(height: 30,),
                  Text('Looking For backup')
                ],
              );
            }
          }),
    ];

    List<Widget> downloadAndRestoreList = [
      StreamBuilder(
          stream: provider.driveDownloadFile(),
          builder: (context, snapshot) {
            if(snapshot.hasError){
              return Text(snapshot.error.toString());
            }else if(snapshot.hasData){
              return snapshot.data as Widget;
            }else{
              return Column(
                children: const[
                  LinearProgressIndicator(),
                  SizedBox(height: 30,),
                  Text('Downloading backup')
                ],
              );
            }
          }),
    ];
    List<Widget> createNewBackupList = [
      StreamBuilder(
          stream: provider.driveUploadFile(),
          builder: (context, snapshot) {
            if(snapshot.hasError){
              return Text(snapshot.error.toString());
            }else if(snapshot.hasData){
              return snapshot.data as Widget;
            }else{
              return Column(
                children: const[
                  LinearProgressIndicator(),
                  SizedBox(height: 30,),
                  Text('Uploading backup')
                ],
              );
            }
          }),
    ];

    switch(mode){
      case 'downloadAndRestore' :
        showList = downloadAndRestoreList;
        break;
      case 'createNewBackup' :
        showList = createNewBackupList;
        break;
      default:
        showList = searchViewList;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Backup'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: showList,
          ),
        ),
      ),
    );
  }



  void downloadAndRestore(){
    mode = 'downloadAndRestore';
    setState(() {
      mode = 'downloadAndRestore';
    });
  }

  void createNewBackup(){
    mode = 'createNewBackup';
    setState(() {
      mode = 'createNewBackup';
    });
  }
}
