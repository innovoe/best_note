import 'package:best_note/demo/home_page.dart';
import 'package:best_note/model/google_user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



class AuthLanding extends StatefulWidget {
  const AuthLanding({Key? key}) : super(key: key);

  @override
  State<AuthLanding> createState() => _AuthLandingState();
}

class _AuthLandingState extends State<AuthLanding> {
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GoogleUser>(context);
    return StreamBuilder(
        stream: provider.authStream,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            // print('in first waiting');
            return landingBody(CircularProgressIndicator());
          }else if(snapshot.hasError){
            // print('has error ${snapshot.error}');
            return view(snapshot.error.toString(), userLoginButton(context, provider.googleLogin));
          }else if(snapshot.hasData){
            if(snapshot.connectionState == ConnectionState.waiting){
              // print('in second waiting');
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            } else if(provider.currentUser() == null){
              // print('current user null');
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            }else{
              return HomePage();
            }
          }else{
            // print('login page bottm last');
            return view('', userLoginButton(context, provider.googleLogin));
          }
        }
    );

  }

  Widget view(String text, Widget signIButton){
    final provider = Provider.of<GoogleUser>(context);
    return Scaffold(
        body: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50,),
                Text('Sign In', style: TextStyle(fontSize: 40),),
                loadingWidget(),
                Text(text),
                signIButton,
                SizedBox(height: 50,),
                Text(
                  'Just one step before you enjoy the best features of Best Note!\nHaving a google account is mandatory for using Best Note. This is for keeping you data backup safe.',
                  textAlign: TextAlign.center,

                ),
                SizedBox(height: 50,),
                OutlinedButton(
                  child: Text('Skip for now'),
                  onPressed: (){
                    Navigator.pushReplacementNamed(context, '/homePage');
                  },
                )
              ],
            ),
          ),
        )
    );
  }

  Widget loadingWidget(){
    if(loading == true){
      return Padding(padding:EdgeInsets.only(top: 15, bottom: 10, left: 30, right: 30),child: LinearProgressIndicator());
    }else{
      return SizedBox(height: 20);
    }
  }

  Widget userLoginButton(context, Function googleLogin){
    final provider = Provider.of<GoogleUser>(context);
    return ElevatedButton(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/google-logo.png'),
              Text('Sign in with Google', style: TextStyle(color: Colors.grey, fontSize: 16),),
              Opacity(opacity: 0, child: Image.asset('assets/google-logo.png'))
            ],
          ),
        ),
        onPressed: (){
          setState(() { loading = true; });
          provider.googleLogin().whenComplete((){
            setState(() { loading = false; });
          });
        },
        style: ElevatedButton.styleFrom(primary: Colors.white)
    );
  }

  Widget landingBody(Widget bodyWidget){
    return Scaffold(
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: bodyWidget,
        )
      ),
    );
  }
}
