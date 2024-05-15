import 'package:best_note/demo/calculative_note.dart';
import 'package:best_note/model/google_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:best_note/demo/image_fullscreen.dart';
import 'package:best_note/demo/note_with_image_video.dart';
import 'package:best_note/demo/stacking.dart';
import 'package:best_note/demo/text_test.dart';
import 'package:best_note/demo/video_testing.dart';
import 'package:best_note/demo/wrapper.dart';
import 'package:best_note/demo/widget_span_test.dart';
import 'package:best_note/demo/image_and_camera.dart';
import 'package:best_note/model/fullscreen_opener.dart';
import 'package:best_note/demo/home_page.dart';
import 'package:best_note/demo/account.dart';
import 'package:provider/provider.dart';
import 'package:best_note/demo/auth_landing.dart';
import 'package:best_note/demo/backup.dart';
import 'package:best_note/model/home_page_note_list.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  return runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => GoogleUser()),
      // StreamProvider(
      //   create: (context) => HomePageNoteList().homePageNoteStream,
      //   initialData: Center(child: CircularProgressIndicator())
      // ),
      // ChangeNotifierProvider(create: (context) => HomePageNoteList())
    ],
    child: MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.deepPurple
      ),
      routes: {
        // '/' : (context) => Landing(),
        '/' : (context) => AuthLanding(),
        '/stacking' : (context) => Stacking(),
        '/textTest' : (context) => TextTest(),
        '/wrapper' : (context) => Wrapper(),
        '/widgetSpanTest' : (context) => WidgetSpanTest(),
        '/videoTesting' : (context) => VideoTesting(),
        '/imageAndCamera' : (context) => ImageAndCamera(),
        '/noteWithImageVideo' : (context) => NoteWithImageVideo(),
        '/imageFullScreen' : (context) => ImageFullScreen(),
        '/fullscreenOpener' : (context) => FullscreenOpener(),
        '/homePage' : (context) => HomePage(),
        '/backup' : (context) => Backup(),
        '/account' : (context) => Account(),
        '/calculativeNote' : (context) => CalculativeNote()
      },
      // navigatorObservers:  [ routeObserver ],
    ),
  ));
}









// Future<void> main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   // final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
//   return runApp(ChangeNotifierProvider(
//     create: (context) => GoogleUser(),
//     child: MaterialApp(
//       theme: ThemeData(
//           primarySwatch: Colors.deepPurple
//       ),
//       routes: {
//         // '/' : (context) => Landing(),
//         '/' : (context) => AuthLanding(),
//         '/stacking' : (context) => Stacking(),
//         '/textTest' : (context) => TextTest(),
//         '/wrapper' : (context) => Wrapper(),
//         '/widgetSpanTest' : (context) => WidgetSpanTest(),
//         '/videoTesting' : (context) => VideoTesting(),
//         '/imageAndCamera' : (context) => ImageAndCamera(),
//         '/noteWithImageVideo' : (context) => NoteWithImageVideo(),
//         '/imageFullScreen' : (context) => ImageFullScreen(),
//         '/fullscreenOpener' : (context) => FullscreenOpener(),
//         '/homePage' : (context) => HomePage(),
//         '/backup' : (context) => Backup(),
//         '/account' : (context) => Account(),
//         '/calculativeNote' : (context) => CalculativeNote()
//       },
//       // navigatorObservers:  [ routeObserver ],
//     ),
//   ));
// }