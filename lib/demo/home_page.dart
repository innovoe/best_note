import 'dart:convert';
import 'package:best_note/model/google_user.dart';
import 'package:best_note/model/home_page_note_list.dart';
import 'package:best_note/model/load_data.dart';
import 'package:flutter/material.dart';
import 'package:best_note/model/bloc.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:permission_handler/permission_handler.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Widget> notes;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPermission();
    homePageNoteList.getNoteNames();
  }

  Future<void> getPermission() async{
    Map<Permission, PermissionStatus> statuses = await [
      Permission.camera,
      Permission.storage,
    ].request();
    // print(statuses[Permission]);
  }

  @override
  Widget build(BuildContext context) {
    notes = [];
    var provider = Provider.of<GoogleUser>(context);

    // if(provider.currentUser() == null) Navigator.pop(context);
    // Widget plusButton = Row(
    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //   children: [
    //     GestureDetector(
    //       onTap: (){
    //         bloc.name = 'none';
    //         Navigator.pushNamed(context, '/noteWithImageVideo');
    //       },
    //       child: newNoteContainer(0),
    //     ),
    //     GestureDetector(
    //       onTap: (){
    //         bloc.name = 'none';
    //         Navigator.pushNamed(context, '/calculativeNote');
    //       },
    //       child: newNoteContainer(1),
    //     )
    //   ],
    // );
    // notes.add(plusButton);

    return Scaffold(
      drawer: sideDrawer(),
      appBar: AppBar(
        title: Text('Best Note (beta version)'),
        actions: [
          GestureDetector(child: provider.userImage(),
            onTap: (){
              if(provider.loggedIn()){
                Navigator.pushNamed(context, '/account');
              }
            },
          ),
          SizedBox(width: 10,)
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.grey[100],
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              label: Text('New Note +'),
              icon: Icon(Icons.edit_note),
              onPressed: (){
                bloc.name = 'none';
                Navigator.pushNamed(context, '/noteWithImageVideo');
              },
            ),
            SizedBox(width: 10,),
            OutlinedButton.icon(
              label: Text('Calculative Note +'),
              icon: Icon(Icons.backup_table),
              onPressed: (){
                bloc.name = 'none';
                Navigator.pushNamed(context, '/calculativeNote');
              },
            ),

          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: ()async{
          homePageNoteList.getNoteNames();
          setState((){});
        },
        child: Stack(
          children: [
            ListView(),
            SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.only(top: 20, bottom: 100),
                child: StreamBuilder<List<String>>(
                  stream: homePageNoteList.homePageNoteStream,
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LinearProgressIndicator(),
                          SizedBox(height: MediaQuery.of(context).size.height/2),
                          OutlinedButton(
                            onPressed: (){
                              homePageNoteList.getNoteNames();
                              setState((){});
                            },
                            child: Icon(Icons.refresh, color: Colors.grey[300],)
                          )
                        ],
                      );
                    }
                    if(snapshot.hasError){
                      return Text(snapshot.error.toString());
                    }
                    else if(snapshot.hasData && snapshot.connectionState == ConnectionState.active){
                      List<String> names =  snapshot.data!;
                      notes.clear();
                      return FutureBuilder(
                        future: getNoteListsFromDirectories(names),
                        builder: (context, snapshot){
                          if(snapshot.hasError){
                            return Text(snapshot.error.toString());
                          }else if(snapshot.hasData){
                            return snapshot.data as Widget;
                          }else{
                            return Center(child: CircularProgressIndicator(),);
                          }
                        }
                      );
                    }else{
                      return Center(child: LinearProgressIndicator(),);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Future<Widget> getNoteListsFromDirectories(List<String> names) async{
    for(String name in names){
      NoteInfo noteInfo = await getNoteInfo(name);
      Widget input = (noteInfo.type == '0') ?
        GestureDetector(
          onTap: (){
            bloc.name = name;
            Navigator.pushNamed(context, '/noteWithImageVideo');
          },
          onLongPress: (){
            alertDelete(name, noteInfo.title);
          },
          child: noteContainer(noteInfo.title, noteInfo.dated, noteInfo.text),
        ) :
        GestureDetector(
          onTap: (){
            bloc.name = name;
            Navigator.pushNamed(context, '/calculativeNote');
          },
          onLongPress: (){
            alertDelete(name, noteInfo.title);
          },
          child: noteContainerCalculative(noteInfo.title, noteInfo.dated, noteInfo.text),
        );
      notes.add(input);
    }
    notes = notes.toSet().toList();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: notes,
    );
  }


  Widget newNoteContainer(int type){
    return Container(
      // child: Text('+ New Note', style: Theme.of(context).textTheme.headline4),
      child: (type == 0) ? Icon(Icons.edit_note, color: Colors.grey,) : Icon(Icons.backup_table, color: Colors.grey,),
      width: MediaQuery.of(context).size.width / 2 - 20,
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(vertical: 7),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
      ),
    );
  }

  Widget noteContainer(String title, String date, String text){
    String noteTitleText = (title == '') ? 'Untitled' : title;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, color: Colors.deepPurple,),
              SizedBox(width: 5,),
              Text(noteTitleText, style: Theme.of(context).textTheme.headline5),
            ],
          ),
          SizedBox(height: 5),
          Text(text),
          SizedBox(height: 15,),
          Text(date, style: TextStyle(color: Colors.grey),)
        ],
      ),
      width: MediaQuery.of(context).size.width - 30,
      margin: EdgeInsets.symmetric(vertical: 7),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(2)),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(.2, .5), //(x,y)
            blurRadius: 1.0,
          ),
        ],
      ),
    );
  }

  Widget noteContainerCalculative(String title, String date, String text){
    String noteTitleText = (title == '') ? 'Untitled' : title;
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.backup_table, color: Colors.deepPurple,),
              SizedBox(width: 5,),
              Text(noteTitleText, style: Theme.of(context).textTheme.headline5),
            ],
          ),
          SizedBox(height: 5),
          Text(text),
          SizedBox(height: 15,),
          Text(date, style: TextStyle(color: Colors.grey),)
        ],
      ),
      width: MediaQuery.of(context).size.width - 30,
      margin: EdgeInsets.symmetric(vertical: 7),
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(2)),
        boxShadow: const [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(.2, .5), //(x,y)
            blurRadius: 1.0,
          ),
        ],
      ),
    );
  }

  Future<NoteInfo> getNoteInfo(String noteName) async{
    LoadData loadData = LoadData(noteName);
    String title = 'Untitled';
    String dated = 'undated';
    String text = '';
    String type = '0';
    String bnData = await loadData.loadJsonFromName();
    String infoData = await loadData.loadInfoFromName();

    if(checkJsonTrim(infoData) == true){
      var jdReadInfo = jsonDecode(infoData);
      title = jdReadInfo['title'].toString();
      dated = jdReadInfo['date'].toString();
      type = jdReadInfo['type'].toString();
    }

    if(checkJsonTrim(bnData) == true){
      if(type == '0'){
        var jsonDecoded = jsonDecode(bnData);
        for(Map<String, dynamic> jd in jsonDecoded){
          if(jd['type'] == 'text'){
            text += jd['value'] + ' ';
          }
        }
      }else{
        Map<String, dynamic> jsonDecodedCalculative = jsonDecode(bnData);
        jsonDecodedCalculative.forEach((key, value) {
          for(Map<String, dynamic> jd in value){
            text += jd['subject'] + ' ';
          }
        });
      }

    }
    String outText = text.length > 99 ? text.substring(0, 100) : text;

    NoteInfo out = NoteInfo(title: title, dated: dated, text: outText, type: type);
    return out;
  }

  bool checkJsonTrim(String jsonString){
    String newString = jsonString.replaceAll('{', '');
    newString = newString.replaceAll('}', '');
    newString = newString.replaceAll('[', '');
    newString = newString.replaceAll(']', '');
    newString = newString.replaceAll(',', '');
    newString = newString.trim();
    if(newString == ''){
      return false;
    }else{
      return true;
    }
  }

  alertDelete(String name, String title){
    return Alert(
      buttons: [
        DialogButton(
          child: Text('Delete'),
          onPressed: () {
            deleteNote(name).whenComplete(() => Navigator.pop(context));
            homePageNoteList.getNoteNames();
            setState((){});
          },
          color: Colors.red,
        ),
        DialogButton(child: Text('Cancel'), onPressed: () => Navigator.pop(context), color: Colors.blueGrey,),
      ],
      context: context,
      title: 'Delete Note?',
      desc: 'Delete $title from your collection?',
    ).show();
  }

  Future<void> deleteNote(name) async{
    LoadData loadData = LoadData(name);
    await loadData.deleteNote();
  }


  Widget sideDrawer(){
    var provider = Provider.of<GoogleUser>(context);
    Widget email = (provider.email != '') ? Text(provider.email, style: TextStyle(color: Colors.white)) : InkWell(child: Text('login with google account', style: TextStyle(color: Colors.white)), onTap: ()=>Navigator.of(context).popUntil((route) => route.isFirst),);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                provider.userImageDrawer(),
                SizedBox(height: 5),
                Text(provider.displayName, style: TextStyle(color: Colors.white)),
                SizedBox(height: 5),
                email
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.deepPurple,
            ),
          ),
          ListTile(
            leading: Icon(Icons.edit_note),
            title: Text('Add a new note'),
            onTap: () {
              bloc.name = 'none';
              Navigator.pushNamed(context, '/noteWithImageVideo');
            },
          ),
          ListTile(
            leading: Icon(Icons.backup_table),
            title: Text('Add a new Calculative Note'),
            onTap: () {
              bloc.name = 'none';
              Navigator.pushNamed(context, '/calculativeNote');
            },
          ),
          ListTile(
            leading: Icon(Icons.backup),
            title: Text('Backup'),
            onTap: () {
              bloc.name = 'none';
              if(provider.loggedIn()){
                Navigator.pushNamed(context, '/backup');
              }else{
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.account_box_rounded),
            title: Text('My Account'),
            onTap: () {
              bloc.name = 'none';
              if(provider.loggedIn()){
                Navigator.pushNamed(context, '/account');
              }else{
                Navigator.pushReplacementNamed(context, '/');
              }

            },
          ),
        ],
      ),
    );
  }


}


class NoteInfo{
  String title;
  String dated;
  String text;
  String type;
  NoteInfo({required this.title, required this.dated, required this.text, required this.type});
}


