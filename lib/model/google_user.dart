import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:best_note/model/bloc.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:io/io.dart' as io;

class GoogleUser extends ChangeNotifier{

  Stream<User?> get authStream => FirebaseAuth.instance.authStateChanges();

  String get displayName => (FirebaseAuth.instance.currentUser == null) ? 'Guest User' : currentUser()!.displayName.toString();
  String get email => (FirebaseAuth.instance.currentUser == null) ? '' : currentUser()!.email.toString();

  User? currentUser(){
    return FirebaseAuth.instance.currentUser!;
  }

  bool loggedIn(){
    return FirebaseAuth.instance.currentUser == null ? false : true;
  }

  GoogleSignInAccount? googleSignInAccount;

  Future<void> googleLogin() async{
    try{
      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [drive.DriveApi.driveScope]
      );
      final googleUser = await googleSignIn.signIn();
      if(googleUser != null){
        googleSignInAccount = googleUser;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
        notifyListeners();
      }else{
        throw Exception('user refused.');
      }
    }catch(e){
      throw Exception(e.toString());
    }finally{

    }
  }

  GoogleUserCircleAvatar googleCircleAvatar(){
    return GoogleUserCircleAvatar(identity: googleSignInAccount!);
  }

  Future<void> logOut(VoidCallback popAll) async{
    popAll();
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
    notifyListeners();
  }

  Widget userImageLarge() => CachedNetworkImage(
    imageUrl: currentUser()!.photoURL!.replaceAll(RegExp('=s96-c'), ''),
    imageBuilder: (context, imageProvider) => CircleAvatar(
      backgroundImage: imageProvider,
      radius: 150,
    )
  );

  Widget userImage2() => CachedNetworkImage(
    imageUrl: currentUser()!.photoURL!,
    imageBuilder: (context, imageProvider) => Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        image: DecorationImage(
          fit: BoxFit.fill,
          image: imageProvider,
        ),
      ),
    ),
    progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );

  Widget userImage() {
    if(FirebaseAuth.instance.currentUser == null){
      return SizedBox.fromSize(
        size: Size.fromRadius(20),
        child: FittedBox(
          child: Icon(Icons.face, color: Colors.white),
        ),
      );
    }else{
      return CachedNetworkImage(
        imageUrl: currentUser()!.photoURL!,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(
              backgroundImage: imageProvider,
              radius: 20,
            ),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }
  }

  Widget userImageDrawer() {
    if(FirebaseAuth.instance.currentUser == null){
      return SizedBox.fromSize(
        size: Size.fromRadius(30),
        child: FittedBox(
          child: Icon(Icons.face, color: Colors.white),
        ),
      );
    }else{
      return CachedNetworkImage(
        imageUrl: currentUser()!.photoURL!,
        imageBuilder: (context, imageProvider) =>
            CircleAvatar(
              backgroundImage: imageProvider,
              radius: 30,
            ),
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
    }

  }


  Stream<Widget> driveUploadFile() async*{
    Directory appDir = await getApplicationDocumentsDirectory();
    String backupFilePath = appDir.path + '/backup/bestNoteBackup.zip';
    String sourcePath = appDir.path + '/bestNoteSaves/';
    Directory sourceDirectory = Directory(sourcePath);
    File backupFile = File(backupFilePath);
    await backupFile.create(recursive: true);
    try{
      yield yieldWithLoader('Compressing');
      await ZipFile.createFromDirectory(
        sourceDir: sourceDirectory,
        zipFile: backupFile
      );
    }catch (e) {
      Stream.error('Error compressing file. Error: $e');
    }finally{
      yield yieldWithLoader('Backup file is ready. Starting upload');
    }
    await Future.delayed(Duration(milliseconds: 300));
    if(googleSignInAccount == null) await googleLogin();
    var authHeaders = await googleSignInAccount?.authHeaders as Map<String, String>;
    var authenticateClient = GoogleAuthClient(authHeaders);
    var driveApi = drive.DriveApi(authenticateClient);

    drive.File fileToUpload = drive.File();
    fileToUpload.name = 'bestNoteBackup.zip';
    try{
      if(bloc.backupId != ''){
        yield yieldWithLoader('Upload new and replacing old file');
        await driveApi.files.update(
          fileToUpload,
          bloc.backupId,
          uploadMedia: drive.Media(backupFile.openRead(), backupFile.lengthSync())
        );
      }else{
        yield yieldWithLoader('Uploading new file');
        await driveApi.files.create(
            fileToUpload,
            uploadMedia: drive.Media(backupFile.openRead(), backupFile.lengthSync())
        );
      }
    }catch(e){
      Stream.error('upload failed : Error : $e');
    }finally{
      yield Column(
        children: const[
          LinearProgressIndicator(value: 1),
          SizedBox(height: 30,),
          Text('Upload Completed'),
        ],
      );
    }
  }

  Stream<Widget> driveDownloadFile() async*{
    try{
      yield yieldWithLoader('Authenticating');
      if(googleSignInAccount == null) await googleLogin();
      var authHeaders = await googleSignInAccount?.authHeaders as Map<String, String>;
      var authenticateClient = GoogleAuthClient(authHeaders);
      var driveApi = drive.DriveApi(authenticateClient);
      yield yieldWithLoader('Downloading File ${bloc.backupId}');
      drive.Media response = await driveApi.files.get(
          bloc.backupId,
          downloadOptions: drive.DownloadOptions.fullMedia
      ) as drive.Media;

      Directory appDir = await getApplicationDocumentsDirectory();
      String backupFilePath = appDir.path + '/backup_download/bestNoteBackup.zip';
      File downloadFile = File(backupFilePath);
      await downloadFile.create(recursive: true);

      List<int> dataStore = [];
      response.stream.listen((data){
        dataStore.insertAll(dataStore.length, data);
      },onDone: (){
        downloadFile.writeAsBytesSync(dataStore);
      }, onError: (e){
        Stream.error('File Writing failed. Error: $e');
      });
      yield yieldWithLoader('Downloading File...');
    }catch(e){
      Stream.error('download failed. Error: $e');
    }finally{
      yield Column(
        children: const[
          LinearProgressIndicator(value: 1),
          SizedBox(height: 30,),
          Text('Download Completed'),
        ],
      );
    }

    await Future.delayed(Duration(milliseconds: 300));
    try{
      yield yieldWithLoader('Extracting File');
      Directory appDir = await getApplicationDocumentsDirectory();
      String backupFilePath = appDir.path + '/backup_download/bestNoteBackup.zip';
      String tempUnzipDir = appDir.path + '/backup_unzip/';
      File zipFile = File(backupFilePath);
      Directory destinationDir = Directory(tempUnzipDir);
      await ZipFile.extractToDirectory(zipFile: zipFile, destinationDir: destinationDir);
      yield yieldWithLoader('Extraction Completed');
      //////////////////***********************************************************
      //get files of temps - backup_unzip
      await Future.delayed(Duration(milliseconds: 500));
      yield yieldWithLoader('Copying new files');
      await Future.delayed(Duration(milliseconds: 500));
      List<String> temp = [];

      Stream<FileSystemEntity> dirList = destinationDir.list(
          recursive: false,
          followLinks: false
      );
      await dirList.listen((dirName) async{
        String name = dirName.toString().split('/').last.replaceAll("'", "");
        temp.add(name);
      }).asFuture();//it does not wait without declaring as future.
      ////
      //get files of origin - bestNoteSaves
      String originPath = appDir.path + '/bestNoteSaves/';
      Directory originDir = Directory(originPath);
      List<String> origin = [];
      Stream<FileSystemEntity> dirListOrigin = originDir.list(
          recursive: false,
          followLinks: false
      );
      await dirListOrigin.listen((dirName) async{
        String name = dirName.toString().split('/').last.replaceAll("'", "");
        origin.add(name);
      }).asFuture();//it does not wait without declaring as future.

      //Compare the lists
      for(String name in temp){
        if(origin.contains(name)) continue;
        String directorySourcePath = tempUnzipDir + name + '/';
        String directoryDestinationPath = originPath + name + '/';
        await io.copyPath(directorySourcePath, directoryDestinationPath);
      }
    }catch(e){
      Stream.error('Trouble extracting zip file. Error: $e');
    }finally{
      await Future.delayed(Duration(seconds: 3));
      yield Column(
        children: const[
          LinearProgressIndicator(value: 1),
          SizedBox(height: 30,),
          Text('Backup Completed'),
        ],
      );
    }
  }



  Future<Widget> driveSearchFile(Function downloadAndRestore, Function createNewBackup) async{
    try{
      if(googleSignInAccount == null) await googleLogin();
      await Future.delayed(Duration(seconds: 5));
      var authHeaders = await googleSignInAccount?.authHeaders as Map<String, String>;
      var authenticateClient = GoogleAuthClient(authHeaders);
      var driveApi = drive.DriveApi(authenticateClient);
      await Future.delayed(Duration(milliseconds: 500));
      drive.FileList fileList = await driveApi.files.list($fields: 'files(createdTime,id,name)');
      await Future.delayed(Duration(milliseconds: 500));
      for(drive.File file in fileList.files!){
        if(file.name == 'bestNoteBackup.zip'){
          bloc.backupId = file.id!;
          String dateTime = file.createdTime!.toString();
          await Future.delayed(Duration(milliseconds: 500));
          return Column(
            children: [
              Text('Found backup file in Google Drive. Created $dateTime.'),
              SizedBox(height: 30,),
              OutlinedButton(
                child: Text('   Create A New Backup   '),
                onPressed: (){
                  createNewBackup();
                },
              ),
              OutlinedButton(
                child: Text('Download & Restore Now'),
                onPressed: (){
                  downloadAndRestore();
                },
              )
            ],
          );
        }
      }
      bloc.backupId = '';
      return Column(
        children: [
          Text('No backup file found in Google Drive. Create a new one'),
          SizedBox(height: 30,),
          OutlinedButton(
            child: Text('Create New Backup'),
            onPressed: (){
              createNewBackup();
            },
          )
        ],
      );
    }catch(e){
      return Future.error('Unable to fetch backup. Something went wrong. Check internet connection and try again. Error: $e');
    }
  }

  Widget yieldWithLoader(String text){
    return Column(
      children: [
        LinearProgressIndicator(),
        SizedBox(height: 30,),
        Text(text)
      ],
    );
  }



}



class GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;

  final http.Client _client = http.Client();

  GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}