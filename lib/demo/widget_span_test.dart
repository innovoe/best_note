import 'package:flutter/material.dart';

class WidgetSpanTest extends StatelessWidget {
  const WidgetSpanTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> urls = [
      'https://cdn.pixabay.com/photo/2020/05/27/05/22/portrait-5225730_960_720.jpg',
      'https://imgv3.fotor.com/images/homepage-feature-card/Fotor-AI-photo-enhancement-tool.jpg',
      'https://thumbs.dreamstime.com/b/image-wood-texture-boardwalk-beautiful-autumn-landscape-background-free-copy-space-use-background-backdrop-to-132997627.jpg',
      'https://www.foleon.com/hubfs/Blogs/5%20sites%20for%20free%20stock%20photos/stockfoto.jpg'
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Widget Span Testing'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20),
          child: Wrap(
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                  children: [
                    TextSpan(text: 'we this this pic '),
                    WidgetSpan(child: Container(
                      child: Image.network(urls[1]),
                      width: 150,
                      margin: EdgeInsets.all(5),
                    )),
                    TextSpan(text: ' for you next project.'),
                  ]
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
