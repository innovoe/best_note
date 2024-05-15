import 'package:flutter/material.dart';

class Stacking extends StatelessWidget {
  const Stacking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> urls = [
      'https://cdn.pixabay.com/photo/2020/05/27/05/22/portrait-5225730_960_720.jpg',
      'https://imgv3.fotor.com/images/homepage-feature-card/Fotor-AI-photo-enhancement-tool.jpg',
      'https://thumbs.dreamstime.com/b/image-wood-texture-boardwalk-beautiful-autumn-landscape-background-free-copy-space-use-background-backdrop-to-132997627.jpg',
      'https://www.foleon.com/hubfs/Blogs/5%20sites%20for%20free%20stock%20photos/stockfoto.jpg'
    ];
    List<Widget> imgBox = [];
    for(int i = 0; i < urls.length; i++){
      String myUrl = urls[i];
      imgBox.add(Container(
        child: Image.network(myUrl),
        width: 150,
        margin: EdgeInsets.all(5),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Media Note'),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hi! This is my note. I love to write here. Please follow my note. I would love to follow you back.'),
            Wrap(
              children: imgBox,
            ),
            Text('Hi! This is Bob. I love to read here. Please follow my note. I would love to follow you back.'),
            Wrap(
              children: [
                imgBox[1],
                imgBox[3]
              ],
            )
          ],
        ),
      ),
    );
  }
}
