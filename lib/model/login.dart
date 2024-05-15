import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  // late bool loggedIn;
  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  late bool loggedIn;
  final List<Widget> loginStack = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Firebase.initializeApp().whenComplete((){
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if(user != null){
          setState(() {
            loggedIn = true;
            loginStack.clear();
            loginStack.add(userImage(user.photoURL!));
            loginStack.add(Text(user.displayName!));
            loginStack.add(logOutButton());
          });
        }else{
          setState(() {
            loginStack.clear();
            loggedIn = false;
            loginStack.add(userLoginButton());
          });

        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: loginStack,
    );
  }

  Widget userImage(String photoUrl) => Container(
    width: 100,
    height: 100,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white,
      image: DecorationImage(
        fit: BoxFit.fill,
        image: NetworkImage(photoUrl),
      ),
    ),
  );

  Widget userLoginButton(){
    return ElevatedButton(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/google-logo.png'),
          Text('Sign in with Google'),
          Opacity(opacity: 0, child: Image.asset('assets/google-logo.png'))
        ],
      ),
      onPressed: (){
        setState(() {
          loginStack.clear();
          loginStack.add(CircularProgressIndicator());
          googleLogin();
        });
      },
    );
  }

  Widget logOutButton(){
    return ElevatedButton(
      child: Text('logout'),
      onPressed: () {
        setState(() {
          logOut();
        });
      }
    );
  }

  Future<void> logOut() async{
    GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();
  }

  Future<void> googleLogin() async{
    GoogleSignIn googleSignIn = GoogleSignIn();
    final googleUser = await googleSignIn.signIn();
    if(googleUser != null){
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

}