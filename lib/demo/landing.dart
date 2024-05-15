import 'package:flutter/material.dart';

class Landing extends StatelessWidget {
  const Landing({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Landing Page'),),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/stacking');
                }, child: Text('stacking'),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/textTest');
                }, child: Text('Text Testing'),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/wrapper');
                }, child: Text('Wrapper'),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/widgetSpanTest');
                }, child: Text('Widget Span Test'),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/videoTesting');
                }, child: Text('Video Testing'),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/imageAndCamera');
                }, child: Text('Image and Camera'),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/videoAdvance');
                }, child: Text('Video Advance'),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/noteWithImageVideo');
                }, child: Text('Note With Image Camera'),
              ),
              ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, '/authLanding');
                }, child: Text('Home Page'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
