import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:best_note/model/google_user.dart';

class Account extends StatelessWidget {
  const Account({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<GoogleUser>(context);
    String displayName = (provider.currentUser()?.displayName == null) ? 'Username' : provider.currentUser()!.displayName.toString();
    String email = (provider.currentUser()?.email == null) ? 'User Email' : provider.currentUser()!.email.toString();
    Widget photo = (provider.currentUser()?.photoURL == null) ? Text('no image') : provider.userImageLarge();
    print(provider.currentUser()!.photoURL);
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              photo,
              SizedBox(height: 30,),
              Text(displayName, style: TextStyle(fontSize: 16)),
              Text(email, style: TextStyle(fontSize: 12)),
              SizedBox(height: 30,),
              ElevatedButton(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('assets/google-logo.png'),
                        Text('Log Out', style: TextStyle(color: Colors.grey, fontSize: 16),),
                        Opacity(opacity: 0, child: Image.asset('assets/google-logo.png'))
                      ],
                    ),
                  ),
                  onPressed: (){
                    provider.logOut((){
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    });
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.white)
              )
            ],
          ),
        ),
      ),
    );
  }
}
